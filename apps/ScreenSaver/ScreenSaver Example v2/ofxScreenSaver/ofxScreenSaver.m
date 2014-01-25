//
//  ofxScreenSaver.cpp
//  ofxScreenSaver
//
//  Created by Nick Hardeman on 1/24/14.
//
//

#include "ofxScreenSaver.h"


@implementation SCREENSAVER_MAIN_CLASS


//--------------------------------------------------------------
- (void) setup {
    NSLog(@"MAIN CLASS SETUP");
    bUseMultiScreen         = NO;
    bEnabledVerticalSync    = NO;
}

//--------------------------------------------------------------
- (BOOL)hasConfigureSheet {
    return NO;
}

@end