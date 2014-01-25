//
//  ofxScreenSaverWindow.h
//  ofxScreenSaver
//
//  Created by Nick Hardeman on 1/24/14.
//
//

#pragma once
#include "ofConstants.h"
#include "ofAppBaseWindow.h"
#include "ofEvents.h"
#include "ofTypes.h"

class ofBaseApp;

class ofxScreenSaverWindow : public ofAppBaseWindow {
public:
    ofxScreenSaverWindow();
    ~ofxScreenSaverWindow();
    
    void setupOpenGL(int w, int h, int screenMode);
    
    void initializeWindow();
	void runAppViaInfiniteLoop(ofBaseApp * appPtr);
    
    void setWindowPosition(int x, int y);
	void setWindowShape(int w, int h);
    
    ofPoint		getWindowPosition();
	ofPoint		getWindowSize();
	ofPoint		getScreenSize();
	
	void			setOrientation(ofOrientation orientation);
	ofOrientation	getOrientation();
    
    int     getWidth();
	int     getHeight();
	
	int     getWindowMode();
    
	void    enableSetupScreen();
	void    disableSetupScreen();
    
	void    setVerticalSync(bool enabled);
    
    void    display();
    
protected:
    int     windowMode;
    bool    bNewScreenMode;
    bool    bEnableSetupScreen;
    
    int     windowW;
    int     windowH;
    int     nFramesSinceWindowResized;
    ofOrientation	orientation;
    ofBaseApp *  ofAppPtr;
    
};











