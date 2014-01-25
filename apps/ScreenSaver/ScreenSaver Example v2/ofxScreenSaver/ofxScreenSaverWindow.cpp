//
//  ofxScreenSaverWindow.cpp
//  ofxScreenSaver
//
//  Created by Nick Hardeman on 1/24/14.
//
//

#include "ofxScreenSaverWindow.h"

#include "ofBaseApp.h"
#include "ofEvents.h"
#include "ofUtils.h"
#include "ofGraphics.h"
#include "ofAppRunner.h"
#include "ofGLProgrammableRenderer.h"
#include <AppKit/AppKit.h>

void ofGLReadyCallback();

//--------------------------------------------------------------
ofxScreenSaverWindow::ofxScreenSaverWindow() {
    ofAppPtr            = NULL;
    
    windowMode          = OF_WINDOW;
    bNewScreenMode      = true;
    bEnableSetupScreen  = true;
    
    windowW             = 0;
    windowH             = 0;
    nFramesSinceWindowResized = 0;
    orientation         = OF_ORIENTATION_DEFAULT;
}

//--------------------------------------------------------------
ofxScreenSaverWindow::~ofxScreenSaverWindow() {
    ofAppPtr = NULL;
}

//--------------------------------------------------------------
void ofxScreenSaverWindow::setupOpenGL(int w, int h, int screenMode) {
    
    windowMode      = screenMode;
	bNewScreenMode  = true;
    
    windowW         = w;
    windowH         = h;
    
    NSLog(@"ofxScreenSaverWindow :: dims %i x %i", w, h);
    
    ofGLReadyCallback();
}

//--------------------------------------------------------------
void ofxScreenSaverWindow::initializeWindow() {
    nFramesSinceWindowResized = 0;
}

//--------------------------------------------------------------
void ofxScreenSaverWindow::runAppViaInfiniteLoop(ofBaseApp * appPtr) {
    ofAppPtr = appPtr;
    
    ofAppPtr->setup();
	ofNotifySetup();
	ofNotifyUpdate();
}

//--------------------------------------------------------------
void ofxScreenSaverWindow::setWindowPosition(int x, int y) {
    ofLogWarning("ofxScreenSaverWindow :: setWindowPosition : can not set the window position");
}

//--------------------------------------------------------------
void ofxScreenSaverWindow::setWindowShape(int w, int h) {
    windowW = w;
    windowH = h;
}

//--------------------------------------------------------------
ofPoint	ofxScreenSaverWindow::getWindowPosition() {
    return ofPoint(0, 0, 0);
}

//--------------------------------------------------------------
ofPoint	ofxScreenSaverWindow::getWindowSize() {
    return ofPoint(windowW, windowH,0);
}

//--------------------------------------------------------------
ofPoint	ofxScreenSaverWindow::getScreenSize() {
    return ofPoint(windowW, windowH,0);
}

//--------------------------------------------------------------
void ofxScreenSaverWindow::setOrientation(ofOrientation orientation) {
    ofLogWarning("ofxScreenSaverWindow :: setOrientation : can not set the window orientation");
}

//--------------------------------------------------------------
ofOrientation ofxScreenSaverWindow::getOrientation() {
    return orientation;
}

//--------------------------------------------------------------
int	ofxScreenSaverWindow::getWidth() {
    return windowW;
}

//--------------------------------------------------------------
int	ofxScreenSaverWindow::getHeight() {
    return windowH;
}

//--------------------------------------------------------------
int ofxScreenSaverWindow::getWindowMode() {
    return windowMode;
}

//--------------------------------------------------------------
void ofxScreenSaverWindow::enableSetupScreen() {
    bEnableSetupScreen = true;
}

//--------------------------------------------------------------
void ofxScreenSaverWindow::disableSetupScreen() {
    bEnableSetupScreen = false;
}

//--------------------------------------------------------------
void ofxScreenSaverWindow::setVerticalSync(bool bSync) {
    // we don't have a gl context right now so this doesn't work //
//    GLint sync = bSync == true ? 1 : 0;
//    CGLSetParameter (CGLGetCurrentContext(), kCGLCPSwapInterval, &sync);
    GLint sanked = 0;
    if(bSync) {
        sanked = 1;
    }
//    if(openGLContext) {
//        NSLog( @"ofxScreenSaverWindow :: setVerticalSync : %i", bSync );
//        [openGLContext setValues:&sanked forParameter:NSOpenGLCPSwapInterval];
//    }
}

//--------------------------------------------------------------
void ofxScreenSaverWindow::display() {
    
    if(ofAppPtr == NULL) return;
    if(!ofGetGLRenderer()) {
        NSLog(@"ofxScreenSaverWindow :: display : NO MORE GL RENDERER!!! ");
        return;
    }
    
	// set viewport, clear the screen
	ofViewport();		// used to be glViewport( 0, 0, width, height );
	float * bgPtr = ofBgColorPtr();
	bool bClearAuto = ofbClearBg();
    
    
	if ( bClearAuto == true || ofGetFrameNum() < 3){
		ofClear(bgPtr[0]*255,bgPtr[1]*255,bgPtr[2]*255, bgPtr[3]*255);
	}
    
	if( bEnableSetupScreen )ofSetupScreen();
    
    ofNotifyDraw();
    ofAppPtr->draw();
    
    if (bClearAuto == false){
        // in accum mode resizing a window is BAD, so we clear on resize events.
        if (nFramesSinceWindowResized < 3){
            ofClear(bgPtr[0]*255,bgPtr[1]*255,bgPtr[2]*255, bgPtr[3]*255);
        }
    }
    
    nFramesSinceWindowResized++;
}





















