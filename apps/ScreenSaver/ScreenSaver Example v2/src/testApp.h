#pragma once

#include "ofMain.h"

class testApp : public ofBaseApp {

public:
    
    void setup();
    void update();
    void draw();
    
    void exit();
    
    void keyPressed( int key );
    void keyReleased( int key );
    
#ifdef OF_APPLICATION
    void mouseMoved(int x, int y );
    void mouseDragged(int x, int y, int button);
    void mousePressed(int x, int y, int button);
    void mouseReleased(int x, int y, int button);
#endif
    
    ofImage image;
};




