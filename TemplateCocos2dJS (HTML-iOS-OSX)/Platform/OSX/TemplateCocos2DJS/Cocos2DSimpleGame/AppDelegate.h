//
//  AppDelegate.h
//  Cocos2DSimpleGame
//
//  Created by Ray Wenderlich on 2/18/13.
//  Copyright Razeware LLC 2013. All rights reserved.
//


#import "cocos2d.h"

@interface Cocos2DSimpleGameAppDelegate : NSObject <NSApplicationDelegate>
{
	NSWindow	*window_;
	CCGLView	*glView_;
}

@property (assign) IBOutlet NSWindow	*window;
@property (assign) IBOutlet CCGLView	*glView;

- (IBAction)toggleFullScreen:(id)sender;

@end
