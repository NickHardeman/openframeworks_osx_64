
//  ofxScreenSaverApp.cpp
//  ofxScreenSaver
//
//  Created by Nick Hardeman on 1/24/14.
//
//

#include "ofxScreenSaverApp.h"
#include "ofxScreenSaverWindow.h"
#include "ofAppRunner.h"
#include "ofTypes.h"
#include "ofUtils.h"
#include "testApp.h"
#include "ofURLFileLoader.h"
#include "Poco/Net/SSLManager.h"
#include "ofTrueTypeFont.h"

//--------------------------------------------------------------
ofxScreenSaverApp::ofxScreenSaverApp() {
    bSetup = false;
    tApp = NULL;
    windowPtr = NULL;
}

//--------------------------------------------------------------
ofxScreenSaverApp::~ofxScreenSaverApp() {
    bSetup = false;
    ofNotifyExit();
}

//--------------------------------------------------------------
void ofxScreenSaverApp::setDataPath( const char* aPath ) {
    string npath = aPath;
    npath += "/data/";
    ofSetDataPathRoot( npath );
}

//--------------------------------------------------------------
void ofxScreenSaverApp::setupOpenGL( int w, int h, bool bPreview) {//, NSOpenGLContext *inGlContext ) {
    if(!bSetup) {
        NSLog(@"***** ofxScreenSaverApp :: setupOpenGL *****");
//        if( !ofGetWindowPtr() ) {
        windowPtr = new ofxScreenSaverWindow();
//        windowPtr->openGLContext = inGlContext;
        ofWindowMode twindowmode = bPreview ? OF_WINDOW : OF_FULLSCREEN;
        ofSetupOpenGL( windowPtr, w, h, twindowmode );
//        }
    }
    bSetup = true;
}

//--------------------------------------------------------------
void ofxScreenSaverApp::runApp() {
    if(bSetup) {
        
        if(windowPtr) {
            windowPtr->initializeWindow();
        }
//
        ofSeedRandom();
        ofResetElapsedTimeCounter();
        
        if(windowPtr) {
            tApp = new testApp();
            windowPtr->runAppViaInfiniteLoop(tApp);
        }
//        ofRunApp( new testApp() );
    }
}

//--------------------------------------------------------------
void ofxScreenSaverApp::update() {
    if(bSetup) {
//        NSLog(@"ofxScreenSaverApp :: update");
        if(windowPtr != NULL) {
            ofNotifyUpdate();
            
            if(tApp) {
                tApp->update();
            }
        }
    }
}

//--------------------------------------------------------------
void ofxScreenSaverApp::display() {
    if(bSetup) {
//        NSLog(@"ofxScreenSaverApp :: display : ");
        if(windowPtr) {
            windowPtr->display();
        }
    }
}

void ofStopURLLoader();
//--------------------------------------------------------------
void ofxScreenSaverApp::exit_cb() {
//    if(bSetup) {
    
        if( tApp ){
            tApp->exit();
            delete tApp;
            tApp = NULL;
        }
        
//        ofExitCallback();
//        ofExit();
//        windowPtr.reset();
//        ofRemoveAllURLRequests();
//        ofStopURLLoader();
//        Poco::Net::SSLManager::instance().shutdown();
        
        
        // try to close quicktime, for non-linux systems:
#if defined(OF_VIDEO_CAPTURE_QUICKTIME) || defined(OF_VIDEO_PLAYER_QUICKTIME)
//        closeQuicktime();
#endif
        
        
        //------------------------
        // try to close freeImage:
//        ofCloseFreeImage();
    
        //------------------------
        // try to close free type:
//        ofTrueTypeFont::finishLibraries();
        
        
        if( windowPtr ){
            delete windowPtr;
            windowPtr = NULL;
        }
//    }
    bSetup = false;
}

//--------------------------------------------------------------
void ofxScreenSaverApp::keyDown_cb( int key ) {
    if(bSetup) {
        ofNotifyKeyPressed( key );
        if(tApp) {
            tApp->keyPressed(key);
        }
    }
}

//--------------------------------------------------------------
void ofxScreenSaverApp::keyUp_cb( int key ) {
    if(bSetup) {
        ofNotifyKeyReleased( key );
        if(tApp) {
            tApp->keyReleased(key);
        }
    }
}

//--------------------------------------------------------------
void ofxScreenSaverApp::windowResized( float w, float h ) {
    if(bSetup) {
        if(windowPtr) {
            windowPtr->setWindowShape(w, h);
        }
//        ofNotifyWindowResized( w, h );
    }
}







