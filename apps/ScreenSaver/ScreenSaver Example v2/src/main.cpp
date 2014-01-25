

//#ifdef OF_SCREEN_SAVER
//    #include "ofxAppMacScreenSaver.h"
//#else

#ifdef OF_APPLICATION
    #include "ofAppGlutWindow.h"
#endif
#include "testApp.h"

#ifdef OF_SCREEN_SAVER
    //========================================================================
    int main( ){
        
//        ofAppGlutWindow window;
//        window.setGlutDisplayString("rgb double depth alpha samples>=4");
//        ofSetupOpenGL(&window, 1024,768, OF_WINDOW);			// <-------- setup the GL context
//        
//        // this kicks off the running of my app
//        // can be OF_WINDOW or OF_FULLSCREEN
//        // pass in width and height too:
//        ofRunApp( new testApp());
        
    }

#else
    //========================================================================
    int main( ){
        
        ofAppGlutWindow window;
        window.setGlutDisplayString("rgb double depth alpha samples>=4");
        ofSetupOpenGL(&window, 1024,768, OF_WINDOW);			// <-------- setup the GL context
        
        // this kicks off the running of my app
        // can be OF_WINDOW or OF_FULLSCREEN
        // pass in width and height too:
        ofRunApp( new testApp());
        
    }
#endif