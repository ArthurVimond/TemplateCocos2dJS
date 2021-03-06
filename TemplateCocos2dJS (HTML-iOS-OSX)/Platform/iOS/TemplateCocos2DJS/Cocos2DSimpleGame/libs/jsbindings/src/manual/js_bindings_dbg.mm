#include <errno.h>
#include <sys/socket.h>
#include <netdb.h>
#include <iostream>
#include <string>
#include <sstream>
#include <vector>
#include <pthread.h>
#include <sched.h>
#include "js_bindings_dbg.h"

using namespace std;

map<string, js::RootedScript*> __scripts;

pthread_t debugThread;
string inData;
string outData;
vector<string> queue;
pthread_mutex_t g_qMutex;
pthread_mutex_t g_rwMutex;
bool vmLock = false;
jsval frame = JSVAL_NULL, script = JSVAL_NULL;
int clientSocket;

#define DEBUGGER_PORT 1337
bool serverAlive = true;

void processInput(string data) {
	NSString* str = [NSString stringWithUTF8String:data.c_str()];
	if (vmLock) {
		pthread_mutex_lock(&g_qMutex);
		queue.push_back(string(data));
		pthread_mutex_unlock(&g_qMutex);
	} else {
		[[JSBCore sharedInstance] performSelector:@selector(debugProcessInput:) onThread:[NSThread mainThread] withObject:str waitUntilDone:YES];
	}
}

void clearBuffers() {
	pthread_mutex_lock(&g_rwMutex);
	{
		// only process input if there's something and we're not locked
		if (inData.length() > 0) {
			processInput(inData);
			inData.clear();
		}
		if (outData.length() > 0) {
			write(clientSocket, outData.c_str(), outData.length());
			outData.clear();
		}
	}
	pthread_mutex_unlock(&g_rwMutex);
}

void* serverEntryPoint(void*)
{
#if TARGET_OS_IPHONE || TARGET_OS_MAC
	// this just in case
	@autoreleasepool
{
#endif
	// init the mutex
	assert(pthread_mutex_init(&g_rwMutex, NULL) == 0);
	assert(pthread_mutex_init(&g_qMutex, NULL) == 0);
	// start a server, accept the connection and keep reading data from it
	struct addrinfo hints, *result, *rp;
	int s;
	memset(&hints, 0, sizeof(struct addrinfo));
	hints.ai_family = AF_INET;
	hints.ai_socktype = SOCK_STREAM; // TCP

	int err;
	stringstream portstr;
	portstr << DEBUGGER_PORT;
	const char* tmp = portstr.str().c_str();
	if ((err = getaddrinfo(NULL, tmp, &hints, &result)) != 0) {
		printf("error: %s\n", gai_strerror(err));
	}

	for (rp = result; rp != NULL; rp = rp->ai_next) {
		if ((s = socket(rp->ai_family, rp->ai_socktype, 0)) < 0) {
			continue;
		}
		int optval = 1;
		if ((setsockopt(s, SOL_SOCKET, SO_REUSEADDR, (char*)&optval, sizeof(optval))) < 0) {
			close(s);
			CCLOG(@"error setting socket options");
			return NULL;
		}
		if ((bind(s, rp->ai_addr, rp->ai_addrlen)) == 0) {
			break;
		}
		close(s);
		s = -1;
	}
	if (s < 0 || rp == NULL) {
		CCLOG(@"error creating/binding socket");
		return NULL;
	}
	
	freeaddrinfo(result);
	
	listen(s, 1);
	while (serverAlive && (clientSocket = accept(s, NULL, NULL)) > 0) {
		// read/write data
		CCLOG(@"debug client connected");
		while (serverAlive) {
			char buf[256];
			int readBytes;
			while ((readBytes = read(clientSocket, buf, 256)) > 0) {
				buf[readBytes] = '\0';
				// no other thread is using this
				inData.append(buf);
				// process any input, send any output
				clearBuffers();
			} // while(read)
		} // while(serverAlive)
	}
	// we're done, destroy the mutex
	pthread_mutex_destroy(&g_rwMutex);
	pthread_mutex_destroy(&g_qMutex);
#if TARGET_OS_IPHONE || TARGET_OS_MAC
}
#endif
	return NULL;
}

@implementation JSBCore (Debugger)

/**
 * if we're on a breakpoint, this will pass the right frame & script
 */
- (void)debugProcessInput:(NSString *)str {
	JSString* jsstr = JS_NewStringCopyZ(_cx, [str UTF8String]);
	jsval argv[3] = {
		STRING_TO_JSVAL(jsstr),
		frame,
		script
	};
	jsval outval;
	JSAutoCompartment ac(_cx, _debugObject);
	JS_CallFunctionName(_cx, _debugObject, "processInput", 3, argv, &outval);
}

- (void)enableDebugger
{
	if (_debugObject == NULL) {
		_debugObject = JSB_NewGlobalObject(_cx, true);
		// these are used in the debug socket
		{
			JS_DefineFunction(_cx, _debugObject, "log", JSBCore_log, 0, JSPROP_READONLY | JSPROP_PERMANENT);
			JS_DefineFunction(_cx, _debugObject, "_bufferWrite", JSBDebug_BufferWrite, 1, JSPROP_READONLY | JSPROP_PERMANENT);
			JS_DefineFunction(_cx, _debugObject, "_bufferRead", JSBDebug_BufferRead, 0, JSPROP_READONLY | JSPROP_PERMANENT);
			JS_DefineFunction(_cx, _debugObject, "_lockVM", JSBDebug_LockExecution, 2, JSPROP_READONLY | JSPROP_PERMANENT);
			JS_DefineFunction(_cx, _debugObject, "_unlockVM", JSBDebug_UnlockExecution, 0, JSPROP_READONLY | JSPROP_PERMANENT);
			[self runScript:@"debugger.js" withContainer:_debugObject];
			
			// prepare the debugger
			jsval argv = OBJECT_TO_JSVAL(_object);
			jsval outval;
			JS_WrapObject(_cx, &_debugObject);
			JSAutoCompartment ac(_cx, _debugObject);
			JS_CallFunctionName(_cx, _debugObject, "_prepareDebugger", 1, &argv, &outval);
		}
		// define the start debugger function
		JS_DefineFunction(_cx, _object, "startDebugger", JSBDebug_StartDebugger, 3, JSPROP_READONLY | JSPROP_PERMANENT);
		// start bg thread
		pthread_create(&debugThread, NULL, serverEntryPoint, NULL);
	}
}

@end

JSBool JSBDebug_StartDebugger(JSContext* cx, unsigned argc, jsval* vp)
{
	JSObject* debugGlobal = [[JSBCore sharedInstance] debugObject];
	if (argc == 3) {
		jsval* argv = JS_ARGV(cx, vp);
		jsval out;
		JS_WrapObject(cx, &debugGlobal);
		JSAutoCompartment ac(cx, debugGlobal);
		JS_CallFunctionName(cx, debugGlobal, "_startDebugger", 3, argv, &out);
		return JS_TRUE;
	}
	return JS_FALSE;
}

JSBool JSBDebug_BufferRead(JSContext* cx, unsigned argc, jsval* vp)
{
    if (argc == 0) {
		JSString* str;
		// this is safe because we're already inside a lock (from clearBuffers)
		if (vmLock) {
			pthread_mutex_lock(&g_rwMutex);
		}
		str = JS_NewStringCopyZ(cx, inData.c_str());
		inData.clear();
		if (vmLock) {
			pthread_mutex_unlock(&g_rwMutex);
		}
		JS_SET_RVAL(cx, vp, STRING_TO_JSVAL(str));
    } else {
        JS_SET_RVAL(cx, vp, JSVAL_NULL);
    }
    return JS_TRUE;
}

JSBool JSBDebug_BufferWrite(JSContext* cx, unsigned argc, jsval* vp)
{
    if (argc == 1) {
        jsval* argv = JS_ARGV(cx, vp);
        const char* str;
		
        JSString* jsstr = JS_ValueToString(cx, argv[0]);
        str = JS_EncodeString(cx, jsstr);

		// this is safe because we're already inside a lock (from clearBuffers)
		outData.append(str);

        JS_free(cx, (void*)str);
    }
    return JS_TRUE;
}

// this should lock the execution of the running thread, waiting for a signal
JSBool JSBDebug_LockExecution(JSContext* cx, unsigned argc, jsval* vp)
{
	assert([NSThread currentThread] == [NSThread mainThread]);
	if (argc == 2) {
		printf("locking vm\n");
		jsval* argv = JS_ARGV(cx, vp);
		frame = argv[0];
		script = argv[1];
		vmLock = true;
		while (vmLock) {
			// try to read the input, if there's anything
			pthread_mutex_lock(&g_qMutex);
			while (queue.size() > 0) {
				vector<string>::iterator first = queue.begin();
				string str = *first;
				NSString *nsstr = [NSString stringWithUTF8String:str.c_str()];
				[[JSBCore sharedInstance] performSelector:@selector(debugProcessInput:) withObject:nsstr];
				queue.erase(first);
			}
			pthread_mutex_unlock(&g_qMutex);
			sched_yield();
		}
		printf("vm unlocked\n");
		frame = JSVAL_NULL;
		script = JSVAL_NULL;
		return JS_TRUE;
	}
	JS_ReportError(cx, "invalid call to _lockVM");
	return JS_FALSE;
}

JSBool JSBDebug_UnlockExecution(JSContext* cx, unsigned argc, jsval* vp)
{
	vmLock = false;
	return JS_TRUE;
}
