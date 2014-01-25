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
    
//    ofDisableArbTex();
    
    NSLog(@"%f ---------------------------------------------------", ofGetElapsedTimef() );
    NSLog(@"testApp :: setup : calling setup = %i x %i", ofGetWidth(), ofGetHeight() );
    NSLog(@"---------------------------------------------------");
    
    
    #ifdef OF_SCREEN_SAVER
        ofLogToConsole();
    #endif
    
    #ifdef OF_APPLICATION
    
    #endif
    
    string ipath = ofToDataPath("of-scanner.png");
    NSString* pooStr = [NSString stringWithCString:ipath.c_str() encoding:[NSString defaultCStringEncoding]];
    NSLog(@"image path = %@", pooStr );
    
    if( !image.loadImage("of-scanner.png")) {
        NSLog(@"Could not load the image!!!!!!!!!!!!!!!!!!!!!!!!!");
    }
    image.setAnchorPercent(.5, .5);
}


//--------------------------------------------------------------
void testApp::update() {
    
}

//--------------------------------------------------------------
void testApp::draw() {
    
    
    ofSetColor(0, 0, 0, 100);
    ofCircle( ofMap(sin(ofGetElapsedTimef()*2.f), -1, 1, ofGetWidth()*.15, ofGetWidth()*.85), 0, 100);
    
    ofSetColor(255, 255, 255);
    
    float tw = image.getWidth();
    float th = image.getHeight();
    if( ofGetHeight() < th ) {
        th = ( (ofGetHeight()-20) / th) * th;
        tw = th;
    }
    
    image.draw( ofMap(cos(ofGetElapsedTimef()*1.5), -1, 1, ofGetWidth()*.1, ofGetWidth()*.9), ofGetHeight()*.5, tw, th);
    
}

//--------------------------------------------------------------
void testApp::exit() {
    NSLog(@"xxxx testApp :: exit xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx ");
    
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











