//
//  ofxScreensaverView.h
//  ofxScreensaver
//
//  Created by Marek Bereza on 06/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//  Additions / Modifications by Nick Hardeman.


#import <ScreenSaver/ScreenSaver.h>
#import "ofxScreenSaverGLView.h"
#import "ofxScreenSaverApp.h"


@interface SCREEN_SAVER_BASE_CLASS : ScreenSaverView {
	SCREENSAVER_GLVIEW *glView;
	// add a configure sheet //
	IBOutlet id configSheet;
	
    BOOL preview;
    BOOL bMainFrame;
    BOOL bGLSetup;
    BOOL bClearBG;
    
    BOOL bUseMultiScreen;
    BOOL bEnabledVerticalSync;
    
    ofxScreenSaverApp* ssApp;
    NSRect bounds;
}

- (void) setup;
- (ScreenSaverDefaults *) getDefaults;

+ (BOOL) getConfigureBoolean : (NSString*)index;
+ (int) getConfigureInteger : (NSString*)index;
- (int) getKeyCodeInt : (NSEvent *)theEvent;

@end









