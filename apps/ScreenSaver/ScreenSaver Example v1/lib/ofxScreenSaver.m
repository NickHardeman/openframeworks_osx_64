//
//  ofxScreensaverView.m
//  ofxScreensaver
//
//  Created by Marek Bereza on 06/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//  Additions / Modifications by Nick Hardeman.

#import "ofxScreenSaver.h"
#import "ofxScreenSaverWrapper.h"

#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)
#define BUNDLE_ID_STRING_LIT @ STRINGIZE2(BUNDLE_IDENTIFIER)
#define SCREENSAVER_CLASS_STRING_LIT @ STRINGIZE2(SCREENSAVER_MAIN_CLASS)
#define SCREENSAVER_GL_VIEW_STRING @ STRINGIZE2(SCREENSAVER_GLVIEW)

@implementation SCREENSAVER_MAIN_CLASS

static BOOL gFirst = YES;

//--------------------------------------------------
static int nextPow2(int a){
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


- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview {
    self = [super initWithFrame:frame isPreview:isPreview];
    
    preview = bMainFrame = bFirst = NO;     // assume failure (pessimist!)
    if ( isPreview ) {
        preview = YES;        // remember this is the preview instance
    } else if ( gFirst ) {    // if the singleton is still true
        gFirst = NO;          // clear the singleton
        bFirst = YES;
    }
    
    // does not work, does not have the screen yet //
    //if ( [[[self window] screen] isEqual:[[NSScreen screens] objectAtIndex:0]]) {
    //    NSLog(@"ofxScreenSaver :: initWithFrame : the screen == mainScreen");
    //    bMainFrame = YES;
    //}
    
    bClearBG = true;
    bSetup = false;
        
    //NSArray* listOfScreens = [NSScreen screens];
        
    //if ((listOfScreens != nil) && ([listOfScreens count] > 0))
    //    bIsMainScreen = NSEqualRects([[[self window] screen] frame], [[listOfScreens objectAtIndex:0] frame]);
        
    //if(!bIsMainScreen) {
    //    NSLog(@"------------------------------------------------------------");
    //    NSLog(@"ofxScreenSaver :: initWithFame : this is NOT the main screen!!!!!!!!!");
    //    NSLog(@"------------------------------------------------------------");
        //return -1;
    //}
    NSLog(@"------------------------------------------------------------");
    NSLog(@"ofxScreenSaver :: initWithFrame : frame rect = %d x %d", (int)frame.size.width, (int)frame.size.height);
    NSLog(@"------------------------------------------------------------");
    //NSLog(@"ofxScreenSaver :: initWithFrame : called %d", initCounter);
    NSLog(@"Module name: %@", MyModuleName);
    NSLog(@"Screen saver main class %@", SCREENSAVER_CLASS_STRING_LIT);
    NSLog(@"GL VIew name = %@", SCREENSAVER_GL_VIEW_STRING);
    
    if (self && (bFirst || preview) ) {
        
        // http://www.cocoabuilder.com/archive/cocoa/234688-nsopenglview-and-antialiasing.html
        // NSOpenGLPFASampleBuffers set to 1, and NSOpenGLPFASamples
        // set to something like 4, 8, or 16
        NSLog(@"ofxScreenSaver :: bFirst = %i preview = %i", bFirst, preview);
        
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
		
		// instantiate the constants //
		ScreenSaverDefaults *defaults;
		
		defaults = [ScreenSaverDefaults defaultsForModuleWithName:MyModuleName];
		
        
//        useRDLogoOption;
//        IBOutlet id useDesignIOLogoOption;
//        IBOutlet id useRandomLogoOption;
        
		// Register our default values
		[defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
									@"YES", @"useRDLogo",
                                    @"NO", @"useDesignIOLogo",
                                    @"NO", @"useRandomLogo",
                                    [NSNumber numberWithInt:500], @"numCircles",
									nil]];
		
		
		
		NSOpenGLPixelFormat *format;
		
		format = [[[NSOpenGLPixelFormat alloc] 
				   initWithAttributes:attributes] autorelease];
		
		//if(bFirst || preview) {
        //if(glView) {
        //    [glView removeFromSuperview];
        //    [glView release];
            //NSLog(@"ofxScreenSaver :: initWithPreview : setting up the openGL context");
            glView = [[SCREENSAVER_GLVIEW alloc] initWithFrame:NSZeroRect pixelFormat:format];
        //}
        //}
		
		if (!glView)
		{             
			NSLog( @"Couldn't initialize OpenGL view." );
			[self autorelease];
			return nil;
		} 
		
        [self addSubview:glView]; 
		[[glView openGLContext] makeCurrentContext];
		
        
        glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
        glHint(GL_POLYGON_SMOOTH_HINT, GL_NICEST);
        
		// enable vertical sync
		GLint i = 1;
		[[glView openGLContext] setValues:&i forParameter:NSOpenGLCPSwapInterval];
		
        
        NSLog(@"ofxScreenSaver :: init step 2 : frame rect = %d x %d", (int)frame.size.width, (int)frame.size.height);
		// do setupping
		//string modName = [MyModuleName UTF8String];
        
        //{
        //    NSArray* listOfScreens = [NSScreen screens];
            
        //    if ((listOfScreens != nil) && ([listOfScreens count] > 0))
        //        return NSEqualRects([self frame], [listOfScreens objectAtIndex:0]);
            
        //    return false;
        //}
        
        //NSLog(@"ofxScreenSaver :: initWithFrame : initing openGL %d", initCounter);
		
        
        //NSScreen* mainScreen = [[NSScreen screens] objectAtIndex:0];
        //if(first) { mainFrame = frame; }
        if(bFirst && !preview ) {
            //printf("----------------------------------------------------------------\n");
            NSLog(@"ofxScreenSaver :: initWithFrame : bFirst, setup() = %d x %d", (int)frame.size.width, (int)frame.size.height);
            //printf("----------------------------------------------------------------\n");
            //bMainFrame = YES;
            const char *s = [[[NSBundle bundleForClass:[self class]] resourcePath] UTF8String];
            init(s);
            setupOpenGL( [[[NSScreen screens] objectAtIndex:0] frame] ); 
            setup();
        }
		
        [self setAnimationTimeInterval:1/60.0];
        
        glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
        // This hint is for antialiasing
        glHint(GL_POLYGON_SMOOTH_HINT, GL_NICEST);
        
    }
    
    if ( [[[self window] screen] isEqual:[[NSScreen screens] objectAtIndex:0]]) {
        NSLog(@"ofxScreenSaver :: initWithFrame : the screen == mainScreen");
        //bMainFrame = YES;
    }
    
//     NSLog(@"ofxScreenSaver :: initWithFrame : at the end of the function");
    
    return self;
}

- (void)startAnimation {
    NSRect initRect = [[[self window] screen] frame];
    NSLog(@"ofxScreenSaver :: startAnimation : %d x %d", (int)initRect.size.width, (int)initRect.size.height);
    
    if ( [[[self window] screen] isEqual:[[NSScreen screens] objectAtIndex:0]] && !preview) {
        NSLog(@"ofxScreenSaver :: startAnimation : the screen == mainScreen");
        bMainFrame = YES;
    }
    
    if(preview && !bSetup) {
        NSLog(@"ofxScreenSaver :: startAnimation : isPreview && !bSetup");
        NSLog(@"trying to get the saverBundle path");
        NSBundle* saverBundle   = [NSBundle bundleForClass: [self class]];
        
        NSString* previewPath   = [saverBundle pathForResource: @"preview" ofType: @"png"];
        previewImage            = [[NSImage alloc] initWithContentsOfFile: previewPath];
        
        glEnable(GL_TEXTURE_2D);
        glGenTextures( 1, &previewTexId );
        
        GLenum	 imageFormat = GL_RGBA;
        glBindTexture(GL_TEXTURE_2D, previewTexId );
        glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
        NSBitmapImageRep* bitmapPreview = [[NSBitmapImageRep alloc] initWithData:[previewImage TIFFRepresentation]];

        imageFormat = GL_RGBA;
        if ([bitmapPreview hasAlpha] == YES) {
            imageFormat = GL_RGBA;
        } else {
            imageFormat = GL_RGB;
        }

        glTexImage2D(GL_TEXTURE_2D, 0, imageFormat, [previewImage size].width, [previewImage size].height,
                     0, imageFormat, GL_UNSIGNED_BYTE, [bitmapPreview bitmapData]);

        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);


        glDisable(GL_TEXTURE_2D);
        
        NSLog(@"---- created both of the iOS textures" );
        
        [bitmapPreview release];
        
        NSLog(@"---- releasing both of the iOS textures" );
    }
    
    if(!bMainFrame && !preview) {
        NSLog(@"ofxScreenSaver :: startAnimation : blacking out screen  %d x %d", (int)initRect.size.width, (int)initRect.size.height);
        
        [self lockFocus]; 
        [[NSColor blackColor] set]; 
        NSRectFill([self bounds]); 
        [self unlockFocus]; 
        
        [[self window] flushWindow];
        
        return;
    }
    
    
    bClearBG = true;
    bSetup = true;
    
    [super startAnimation];
}

- (void)stopAnimation
{
    NSLog(@"ofxScreenSaver :: stopAnimation : ");
    //NSLog(@"--");
    //NSLog(@"--");
    exit_cb();
    gFirst      = YES;
    bClearBG    = true;
    preview     = true;
    [super stopAnimation];
}

- (void)drawRect:(NSRect)rect {
    
    [super drawRect:rect];
    
    if(bMainFrame && !preview && bSetup) {
//        NSLog(@"ofxScreenSaver :: drawRect : bMainFrame && !preview && bSetup");
        [[glView openGLContext] makeCurrentContext];
        // now do drawing
        display();
        
        [[glView openGLContext] flushBuffer];
        
    }
    if(preview && bSetup) {
//        NSLog(@"ofxScreenSaver :: drawRect : preview");
        [[glView openGLContext] makeCurrentContext];
        
        glClearColor(0., 0., 0., 1.);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        glLoadIdentity();
        
        
        glColor4f(1., 1., 1., 1.f);
        
        glEnable(GL_TEXTURE_2D);
        glBindTexture(GL_TEXTURE_2D, previewTexId);
        
        [self drawFSQuad];
        
        glBindTexture(GL_TEXTURE_2D, 0);
        glDisable(GL_TEXTURE_2D);
        
        [[glView openGLContext] flushBuffer];
    }
    // draw the other screens //
    if(!preview && !bMainFrame) {
        //NSLog(@"ofxScreenSaver :: drawRect : drawing the blacked out screen");
        //glClearColor(0., 0., 0., 0.);
        //glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        //glColor3f(0., 0., 0.);
        // ADD THE DRAWING CODE FOR THE NTH MONITOR(S) HERE
        //[super drawRect:rect];    // draw the default black background 
    }
}


- (void)setFrameSize:(NSSize)newSize
{
	[super setFrameSize:newSize];
	[glView setFrameSize:newSize]; 
	
	[[glView openGLContext] makeCurrentContext];
	
	// call windowResized
	resize_cb(newSize.width, newSize.height);
	[[glView openGLContext] update];
}


- (void)animateOneFrame {
//    NSLog(@"animateOneFrame :: here you go");
    if(!bSetup) return;
    if(!preview && !bMainFrame) return;
	if(bFirst && !preview) idle_cb();
	// Redraw
	[self setNeedsDisplay:YES];
    return;
}

- (void) drawFSQuad {
    glBegin(GL_QUADS);
        glTexCoord2f(0.0f, 0.); 
        glVertex2f(-1., 1.f);
        
        glTexCoord2f(1., 0.); 
        glVertex2f( 1., 1.);
        
        glTexCoord2f(1., 1.); 
        glVertex2f( 1., -1.);
        
        glTexCoord2f(0.0f, 1.0); 
        glVertex2f(-1, -1);
    glEnd();
}

- (void)keyDown:(NSEvent *)theEvent {
    //  handle any necessary keyDown events here and pass the rest on to the superclass
    //if([[theEvent charactersIgnoringModifiers] isEqualTo:@"s"]) {
        //NSLog(@"HIT THE S KEY");
    
    //NSLog(@"ofxScreenSaver :: keyDown : %s", [ [theEvent charactersIgnoringModifiers] UTF8String]);
    //keyDown_cb( [ [theEvent charactersIgnoringModifiers] UTF8String] );
    
    if([self getKeyCodeInt:theEvent] != -1) {
        //NSLog(@"ofxScreenSaver :: keyDown : the event is %d", [self getKeyCodeInt:theEvent]);
        //int buf[3];
        //sprintf( buf, "%d", (int)357 );
        keyDown_cb( [self getKeyCodeInt:theEvent] );
    } else {
        keyDown_cb([ [theEvent charactersIgnoringModifiers] UTF8String][0]);
    }
        
    //} else {
        //[super keyDown: theEvent];
    //}
}
- (void)keyUp:(NSEvent *)theEvent {
    //  handle any necessary keyUp events here and pass the rest on to the superclass
    if([self getKeyCodeInt:theEvent] != -1) {
        keyUp_cb( [self getKeyCodeInt:theEvent] );
    } else {
        keyUp_cb([ [theEvent charactersIgnoringModifiers] UTF8String][0]);
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
	
    printf("ofxScreenSaver :: calling okClick : \n");
	// Save the settings to disk
	[defaults synchronize];
    
    bClearBG = true;
	
	// Close the sheet
	[[NSApplication sharedApplication] endSheet:configSheet];
}

- (IBAction)cancelClick:(id)sender {
	[[NSApplication sharedApplication] endSheet:configSheet];
}

- (void)dealloc
{
    NSLog(@"ofxScreenSaver :: dealloc : xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
    if(previewImage ) [previewImage release];
    if(bFirst) exit_cb();
	[glView removeFromSuperview];
	[glView release];
	[super dealloc];
}

@end


