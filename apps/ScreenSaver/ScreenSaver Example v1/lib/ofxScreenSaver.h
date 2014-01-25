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

@interface SCREENSAVER_MAIN_CLASS : ScreenSaverView
{
	SCREENSAVER_GLVIEW *glView;
	// add a configure sheet //
	IBOutlet id configSheet;
	
    BOOL preview;
    BOOL bFirst;
    BOOL bMainFrame;
    BOOL bSetup;
    
    BOOL bGLViewSetup;
    
    BOOL bClearBG;
    
    GLuint previewTexId;
    NSImage* previewImage;
    
}
+ (BOOL) getConfigureBoolean : (NSString*)index;
+ (int) getConfigureInteger : (NSString*)index;
- (void) drawFSQuad;
- (int) getKeyCodeInt : (NSEvent *)theEvent;

@end









