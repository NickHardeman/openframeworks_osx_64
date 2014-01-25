#include "testApp.h"
#ifdef OF_SCREEN_SAVER
    #include "ofxScreenSaver.h"
#endif


//--------------------------------------------------------------
void testApp::setup() {
    ofSetFrameRate(60);
//    ofEnableSmoothing();
    ofSetVerticalSync(true);
    //ofSetWindowPosition(1800, 0);
    //ofSetFullscreen(true);
    ofBackground(230,0,0);
    
    ofDisableArbTex();
    
    cout << "---------------------------------------------------" << endl;
    cout << "testApp :: setup : calling setup " << ofGetWidth() << " x " << ofGetHeight() << endl;
    cout << "---------------------------------------------------" << endl;
    
    
    bFirstRun               = true;
    
    
    #ifdef OF_SCREEN_SAVER
        ofLogToConsole();
    #endif
    
    #ifdef OF_APPLICATION
    
    #endif
    
    
    bIsSetup        = true;
    
    
}


//--------------------------------------------------------------
void testApp::update() {
//    NSLog(@"UPDATE ! %llu", ofGetElapsedTimeMillis() );
}

//--------------------------------------------------------------
void testApp::draw() {
    
    if(bFirstDraw) {
        NSLog(@"testApp :: draw : first draw!");
    } else {
//        ofEnableAlphaBlending();
        
//        glEnable(GL_BLEND);
        
//#ifndef TARGET_OPENGLES
//        glBlendEquation(GL_FUNC_ADD);
//#endif
//        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        
        
        
//        glDisable(GL_BLEND);
    }
    
//    NSLog(@"testApp :: draw : %i", ofGetElapsedTimeMillis() );
    
    ofSetColor(0, 0, 0);
    ofCircle( 0, 0, 20000);
    
    bFirstDraw = false;
}

//--------------------------------------------------------------
void testApp::exit() {
    cout << "testApp :: exit : " << endl;
    
}

//--------------------------------------------------------------
void testApp::keyPressed( int key ) {
    
}

//--------------------------------------------------------------
void testApp::keyReleased( int key ) {
    
}

#ifdef OF_APPLICATION
//--------------------------------------------------------------
void testApp::mouseMoved(int x, int y ){
    
}

//--------------------------------------------------------------
void testApp::mouseDragged(int x, int y, int button){
    
}

//--------------------------------------------------------------
void testApp::mousePressed(int x, int y, int button){
    
}

//--------------------------------------------------------------
void testApp::mouseReleased(int x, int y, int button){
    
}
#endif











