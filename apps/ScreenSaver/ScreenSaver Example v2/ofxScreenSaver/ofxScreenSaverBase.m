//
//  ofxScreensaverView.m
//  ofxScreensaver
//
//  Created by Marek Bereza on 06/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//  Additions / Modifications by Nick Hardeman.

#import "ofxScreenSaverBase.h"

#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)
#define BUNDLE_ID_STRING_LIT @ STRINGIZE2(BUNDLE_IDENTIFIER)
#define SCREENSAVER_CLASS_STRING_LIT @ STRINGIZE2(SCREENSAVER_MAIN_CLASS)
#define SCREENSAVER_GL_VIEW_STRING @ STRINGIZE2(SCREENSAVER_GLVIEW)

@implementation SCREEN_SAVER_BASE_CLASS


static BOOL gFirst = YES;

//--------------------------------------------------
static int nextPow2(int a) {
	// from nehe.gamedev.net lesson 43
	int rval=1;
	while(rval<a) rval<<=1;
	return rval;
}

static NSString* const MyModuleName = BUNDLE_ID_STRING_LIT;
//--------------------------------------------------------------
+ (BOOL) getConfigureBoolean : (NSString*)index {
	ScreenSaverDefaults *defaults;
	defaults = [ScreenSaverDefaults defaultsForModuleWithName:MyModuleName];
    
	return (bool)[defaults boolForKey:index];
}

//--------------------------------------------------------------
+ (int) getConfigureInteger : (NSString*)index {
	ScreenSaverDefaults *defaults;
	defaults = [ScreenSaverDefaults defaultsForModuleWithName:MyModuleName];
    
	return (int)[defaults integerForKey:index];
}

//--------------------------------------------------------------
- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview {
    self = [super initWithFrame:frame isPreview:isPreview];
    
    [self setup];
    
    ssApp = NULL;
    
    preview = bMainFrame = NO;
    BOOL bFirstMonitor = NO;
    
    if(isPreview) {
        preview = YES;
    } else {
        if(gFirst) {
            bFirstMonitor = YES;
            gFirst = NO;
        }
    }
    
    // does not work, does not have the screen yet //
    //if ( [[[self window] screen] isEqual:[[NSScreen screens] objectAtIndex:0]]) {
    //    NSLog(@"ofxScreenSaver :: initWithFrame : the screen == mainScreen");
    //    bMainFrame = YES;
    //}
    
    bClearBG = true;
    glView = false;
    
    
    //NSArray* listOfScreens = [NSScreen screens];
        
    //if ((listOfScreens != nil) && ([listOfScreens count] > 0))
    //    bIsMainScreen = NSEqualRects([[[self window] screen] frame], [[listOfScreens objectAtIndex:0] frame]);
    NSLog(@"------------------------------------------------------------");
    NSLog(@"ofxScreenSaver :: initWithFrame : frame rect = %d x %d", (int)frame.size.width, (int)frame.size.height);
    NSLog(@"------------------------------------------------------------");
    if(!glView) {
        NSLog(@"ofxScreenSaver :: there is no GLVIEW!!");
    } else {
        NSLog(@"ofxScreenSaver :: there is already a GLVIEW!!");
    }
//    NSLog(@"Module name: %@", MyModuleName);
//    NSLog(@"Screen saver main class %@", SCREENSAVER_CLASS_STRING_LIT);
    
//    if ( [[[self window] screen] isEqual:[[NSScreen screens] objectAtIndex:0]] || preview ) {
//        NSLog(@"ofxScreenSaver :: initWithRect : the screen == mainScreen preview = %i", preview);
//        bMainFrame = YES;
//    }
//    NSLog(@"GL VIew name = %@", SCREENSAVER_GL_VIEW_STRING);
    
    if ( self && (preview || (bFirstMonitor || bUseMultiScreen) ) ) {
        
        // http://www.cocoabuilder.com/archive/cocoa/234688-nsopenglview-and-antialiasing.html
        // NSOpenGLPFASampleBuffers set to 1, and NSOpenGLPFASamples
        // set to something like 4, 8, or 16
//        NSLog(@"ofxScreenSaver :: setting up openGL context, gFirst = %i preview = %i", gFirst, preview);
        
        NSOpenGLPixelFormatAttribute attributes[] = {
            NSOpenGLPFAAccelerated,
            NSOpenGLPFADoubleBuffer,
            //NSOpenGLPFAMultiScreen,
            NSOpenGLPFASampleBuffers, 1,
            NSOpenGLPFASamples, 8,
            NSOpenGLPFADepthSize, 24,
            NSOpenGLPFAAlphaSize, 8,
            NSOpenGLPFAColorSize, 24,
            NSOpenGLPFANoRecovery,
            0
            
        };
        
        
        NSOpenGLPixelFormat *format;
        
        format = [[[NSOpenGLPixelFormat alloc]
                   initWithAttributes:attributes] autorelease];
        
        glView = [[SCREENSAVER_GLVIEW alloc] initWithFrame:NSZeroRect pixelFormat:format];
        
        // vertical sync
        if(bEnabledVerticalSync) {
            GLint i = 1;
            [[glView openGLContext] setValues:&i forParameter:NSOpenGLCPSwapInterval];
        }
        
        [self addSubview:glView];
        [[glView openGLContext] makeCurrentContext];
        
        
        glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
        glHint(GL_POLYGON_SMOOTH_HINT, GL_NICEST);
        
        glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
        // This hint is for antialiasing
        glHint(GL_POLYGON_SMOOTH_HINT, GL_NICEST);
        
        
        [self setAnimationTimeInterval:1/60.0];
        
		
        bounds = frame;
        
    }
    
//     NSLog(@"ofxScreenSaver :: initWithFrame : at the end of the function");
    
    return self;
}

- (void) setup {
    bUseMultiScreen         = NO;
    bEnabledVerticalSync    = NO;
}

- (ScreenSaverDefaults *)getDefaults {
	return [ScreenSaverDefaults defaultsForModuleWithName:MyModuleName];
}

- (void)startAnimation {
//    NSLog(@"ofxScreenSaver :: startAnimation : %d x %d", (int)initRect.size.width, (int)initRect.size.height);
    
    if ( [[[self window] screen] isEqual:[[NSScreen screens] objectAtIndex:0]] || preview ) {
        NSLog(@"ofxScreenSaver :: startAnimation : the screen == mainScreen preview = %i", preview);
        bMainFrame = YES;
    }
    
    if(bMainFrame || bUseMultiScreen) {
        if(ssApp == NULL ) {
            
            if(glView) {
                [[glView openGLContext] makeCurrentContext];
            }
            
            NSLog(@"ofxScreenSaver :: startAnimation : ssApp == NULL, creating a new one");
            ssApp = new ofxScreenSaverApp();
            const char *s = [[[NSBundle bundleForClass:[self class]] resourcePath] UTF8String];
            ssApp->setDataPath( s );
            
//            ssApp->setupOpenGL( bounds.size.width, bounds.size.height, preview, [glView openGLContext] );
            ssApp->setupOpenGL( bounds.size.width, bounds.size.height, preview );
            ssApp->runApp();
        }
    }
    
    
    if(!bMainFrame && !preview && !bUseMultiScreen) {
        NSLog(@"ofxScreenSaver :: startAnimation : blacking out screen  %d x %d", (int)bounds.size.width, (int)bounds.size.height);
        
        [self lockFocus]; 
        [[NSColor blackColor] set]; 
        NSRectFill([self bounds]); 
        [self unlockFocus]; 
        
        [[self window] flushWindow];
        
        return;
    }
    
    
    bClearBG = true;
//    bSetup = true;
    
    [super startAnimation];
}

- (void)stopAnimation {
    NSLog(@"ofxScreenSaver :: stopAnimation : ");
    
    if(ssApp != NULL) {
        ssApp->exit_cb();
        delete ssApp;
        ssApp = NULL;
    }
    
    if(glView) {
        [NSOpenGLContext clearCurrentContext];
    }
    
    bClearBG    = true;
    [super stopAnimation];
}

- (void)drawRect:(NSRect)rect {
    
    [super drawRect:rect];
    
    if( (bMainFrame && glView) || (bUseMultiScreen && glView) ) {
        
        [[glView openGLContext] makeCurrentContext];
        if( ssApp != NULL ) {
            ssApp->display();
        }

        [[glView openGLContext] flushBuffer];
    }
    
}


- (void)setFrameSize:(NSSize)newSize
{
	[super setFrameSize:newSize];
	[glView setFrameSize:newSize]; 
	
	[[glView openGLContext] makeCurrentContext];
	
	// call windowResized
    if( ssApp != NULL ) {
        ssApp->windowResized( newSize.width, newSize.height );
    }
    
	[[glView openGLContext] update];
}


- (void)animateOneFrame {
    if( !bMainFrame && !bUseMultiScreen ) return;
    if( ssApp != NULL ) {
        ssApp->update();
    }
	// Redraw
	[self setNeedsDisplay:YES];
    return;
}

- (void)keyDown:(NSEvent *)theEvent {
    if([self getKeyCodeInt:theEvent] != -1) {
        if( ssApp != NULL ) {
            ssApp->keyDown_cb( [self getKeyCodeInt:theEvent] );
        }
    } else {
        if( ssApp != NULL ) {
            ssApp->keyDown_cb( [ [theEvent charactersIgnoringModifiers] UTF8String][0] );
        }
    }
        
    //} else {
        //[super keyDown: theEvent];
    //}
}
- (void)keyUp:(NSEvent *)theEvent {
    //  handle any necessary keyUp events here and pass the rest on to the superclass
    if([self getKeyCodeInt:theEvent] != -1) {
        if( ssApp != NULL ) {
            ssApp->keyUp_cb( [self getKeyCodeInt:theEvent ]);
        }
    } else {
        if( ssApp != NULL ) {
            ssApp->keyUp_cb( [ [theEvent charactersIgnoringModifiers] UTF8String][0] );
        }
    }
    //[super keyUp: theEvent];
}

- (int) getKeyCodeInt : (NSEvent *)theEvent {
    switch ( [theEvent keyCode] ) {
        case 126: // up arrow //
            return  357;
            break;
        case 125: // down arrow //
            return 359;
            break;
        case 124: // right arrow //
            return 358;
            break;
        case 123: // left arrow //
            return 356;
            break;
    }
    return -1;
}

- (BOOL)hasConfigureSheet
{
    return NO;
}

- (NSWindow *)configureSheet {
	ScreenSaverDefaults *defaults;
	
	defaults = [ScreenSaverDefaults defaultsForModuleWithName:MyModuleName];
	
	if (!configSheet)
	{
		if (![NSBundle loadNibNamed:@"ConfigureSheet" owner:self]) 
		{
			NSLog( @"Failed to load configure sheet." );
			NSBeep();
		}
	}
	
	
	return configSheet;
}

- (IBAction) okClick: (id)sender
{
	ScreenSaverDefaults *defaults;
	
	defaults = [ScreenSaverDefaults defaultsForModuleWithName:MyModuleName];
	
	// Update our defaults
    
	// Save the settings to disk
	[defaults synchronize];
    
    bClearBG = true;
	
	// Close the sheet
	[[NSApplication sharedApplication] endSheet:configSheet];
}

- (IBAction)cancelClick:(id)sender {
	[[NSApplication sharedApplication] endSheet:configSheet];
}

- (void)dealloc {
    NSLog(@"ofxScreenSaver :: dealloc : bMainFrame = %i preview = %i xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", bMainFrame, preview);
    
//    if(ssApp != NULL) {
//        NSLog(@"ofxScreenSaver :: calling exit_cb xxxxxxxxx");
//        ssApp->exit_cb();
//        delete ssApp;
//        ssApp = NULL;
//    }
    
    if(glView) {
        [NSOpenGLContext clearCurrentContext];
        [glView removeFromSuperview];
        [glView release];
    }
    
    if(bMainFrame && !preview) {
        gFirst = YES;
    }
    
	[super dealloc];
}

@end


