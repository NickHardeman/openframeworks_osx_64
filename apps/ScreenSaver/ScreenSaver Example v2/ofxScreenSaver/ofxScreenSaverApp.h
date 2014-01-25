//
//  ofxScreenSaverApp.h
//  ofxScreenSaver
//
//  Created by Nick Hardeman on 1/24/14.
//
//

#pragma once

class testApp;
class ofxScreenSaverWindow;

class ofxScreenSaverApp {
public:
    
    ofxScreenSaverApp();
    ~ofxScreenSaverApp();
    
    void setDataPath( const char* aPath );
    void setupOpenGL( int w, int h, bool bPreview );//, NSOpenGLContext *inGlContext );
    void runApp();
    
    void update();
    void display();
    void exit_cb();
    
    void keyDown_cb( int key );
    void keyUp_cb( int key );
    
    void windowResized( float w, float h);
    
    bool bSetup;
    
    ofxScreenSaverWindow  * windowPtr;
    testApp * tApp;
    
}; 
