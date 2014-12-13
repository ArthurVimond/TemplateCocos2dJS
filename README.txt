**************************************
** Template for Cocos2d-x projects  **
** 	  (with Javascript binding) 	**
** Copyright (c) 2014 Arthur VIMOND **
**************************************

- The folder "TemplateCocos2dJS (Android-Windows)" is the project for Android and Windows version.
This folder should be placed in :
	(your development or work folder)/cocos2d-x-2.2.3/projects/

This folder was created with the ./create_project.py method (located in cocos2d-x-2.2.3/tools/project-creator/), so you could also create a new project by your own (cf cocos2d-x documentation), but you'll need to apply some modification in order to have the same source code than other platforms.

*********************
** Android version **
*********************

Requirements:
	ADT (Eclipse with Android SDK) : http://developer.android.com/sdk/index.html
	Android NDK : http://developer.android.com/tools/sdk/ndk/index.html
	cocos2d-x : http://www.cocos2d-x.org/download
	command-line knowledge
	patience...

Prerequisite : Setup SDK, NDK and PATH environment variables (use "nano .bash_profile" in command-line);

1- Download Cocos2d-x (http://www.cocos2d-x.org/download): choose v2.2.3 (not v3.1.1)
2- Unzip the folder in a sure place (your development folder, for example)
3- Inside this folder, create a new folder called "projects", this will be all your cocos2d-x for Android / Windows apps folder. ("projects" folder is automatically created when you create a new project with ./create_project.py method.)
4- Move the "TemplateCocos2dJS (Android-Windows)" folder in "projects" folder.
5- Rename it as your app name (eg: "MyGame"). You always could change it after.
6- In Sublime Text, open the entire "proj.android" folder. It will appear in the left side. Open "build_native.sh" file and, at the first line, change the APPNAME "TemplateCocos2dJS" with your application name: APPNAME="MyGame", then close this file.
7- Open "build.xml" file and, at the line 2, change the name in <project name="TemplateCocos2dJS"... with your application name: <project name="MyGame"..., then save and close this file.
8- Open ".project" file and, at the line 3, replace the <name>TemplateCocos2dJS</name> with your application name: <name>MyGame</name>, then save and close this file.
9- Open ADT (Eclipse)
10- File / Import (Cmd + Shift + I) / Android / Existing Android Code into Workspace / Next
	-> Root Directory -> Browse : cocos2d-x.2.2.3/cocos2dx/platform/android/java (Choose "java" folder) -> Open -> Finish
	The project "libcoco2dx" will appear in the Project Explorer (left side).
11- File / Import / Android / Existing Android Code into Workspace / Next
	-> Root Directory -> Browse : cocos2d-x-2.2.3/projects/MyGame -> Open -> Finish
	The project "MyGame" will appear in the Project Explorer (left side).
12- Automatically, the C++ library will compile - It takes a few minutes - Check the console
	Wait until you have the message "XX:XX:XX Build Finished (took XXs.XXXms)" in blue.
	NOTE: If you have a red "make: no rule to make target..." error message in the console, remove your project from the project explorer, delete the "obj" folder of your "proj.android" folder in the finder, then re-import it in ADT.
13- Select "MyGame" project and build it : Menu / Run / Run As / Android Application

!! -> The application will be installed on your device !!

-> To change the package name of your app : Right-click on "MyGame" project in the package explorer / Android Tools / Rename Application Package -> rename it like : com.yourcompany.appname
NB: The package name is a unique identifier which identify your app on Android market and on your device once installed. If you have application updates in the future, you have to keep the same package name for this app.

-> To change app icon and app name which will appear on your device, check the "AndroidManifest.xml" file.


*********************
** Windows version **
*********************

Not tested yet.


*************************
** iOS and OSX version **
*************************

Requirements:
	Xcode
	Valid provisionning profile and certificate (cf Apple developer program)

1- Move the "TemplateCocos2dJS (HTML-iOS-OSX)" folder in another place than (or next to) the cocos2d-x-2.2.3/projects folder.
2- Rename it as your app name (eg: "MyGame"). You always could change it after.
3- In "Platform" folder, there are three versions : HTML5 - iOS - OSX (Mac)
4- Choose the iOS or OSX folder and open the blue file "TemplateCocos2DJS.xcodeproj". It will open Xcode.
5- In Xcode, you can change the settings (icons, splash screens, bundle identifier and app name).
5- To change the app name:
	- Select the blue root directory name "TemplateCocos2DJS"
	- Click on its text -> the name must be editable now
	- Change it as your app name
	- Press Enter
	- A window appear proposing to do some modification -> Click "Rename"
	- A window appear proposing to enable Snapshots -> Click "Disable" (or "Enable" -> it doesn't matter)
	-> You app name is now changed !
6- To change the bundle identifer:
	- Go in the yellow "Resources" folder and find the "Info.plist" file
	- At the line "Bundle identifier", change the value in the right like : com.yourcompany.appname
		NB: The symbol "${PRODUCT_NAME:rfc1034identifier}" means that it take the name of the blue root app folder, you can always change it as you want. As well, to change the app name, you can also change the line "Bundle display name" and replace the "${PRODUCT_NAME}" symbol with what you want.
6- To compile you application :
	- Check you target deployment (Simulator or physical device)
	- Click the "Run" button in top-left (or Menu / Product / Run) (Cmd + R).

!! -> The application will be installed on your device !!

This is the same process for Mac OSX version.


*******************
** HTML5 version **
*******************

1- HTML5 version is the easiest one. Just open the index.html page in a web browser.

NB: To host it on your website, you have to host the Platform/HTML5 folder ("iOS" and "OSX" folders are not necessary for HTML5 version).


***********************
** Resources folders **
***********************

- For HTML5, iOS and OSX versions, you can put your medias (images, sounds, fonts, tilemaps etc...) in the different respective folders (named "img", "sound", "font", "tilemap" etc...) at the root of the index.html page.

- For Android and Windows versions, you have to put your medias in Resources/res folder, then use these different folders (img, sound, font, tilemap etc...).


*****************************************
** Same Source Code for all platforms  **
*****************************************

- HTML5, iOS and OSX's source code and resources are linked together.
- Android and Windows's source code and resources are linked together.

-> In order to have the same source code and resources for all platforms, you have to do some modifications :
	- for every layer (eg: MainLayer.js, MenuLayer.js, GameLayer.js etc...):
		-> copy the content of your layer variable inside your XXXLayer.js of HTML5/iOS/OSX version and paste it in your XXXLayer.js of Android/Windows version.
		-> don't copy the "main.js" file of HTML5/iOS/OSX version (Android/Windows version don't need it).
		-> don't replace the "resources.js" file directly but rather add the media variables inside the file.



******************
** ! Have fun ! **
******************