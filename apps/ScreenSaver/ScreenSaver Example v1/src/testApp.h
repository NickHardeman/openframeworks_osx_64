#pragma once

#include "ofMain.h"

class testApp : public ofBaseApp {

public:
    bool bIsSetup, bFirstDraw;
    testApp() {bIsSetup = false; bFirstDraw = true;}
    
    void setup();
    void update();
    void draw();
    
    void keyPressed( int key );
    void keyReleased( int key );
    
    void exit();
    
#ifdef OF_APPLICATION
    void mouseMoved(int x, int y );
    void mouseDragged(int x, int y, int button);
    void mousePressed(int x, int y, int button);
    void mouseReleased(int x, int y, int button);
#endif
    
    bool bFirstRun;
    
};




