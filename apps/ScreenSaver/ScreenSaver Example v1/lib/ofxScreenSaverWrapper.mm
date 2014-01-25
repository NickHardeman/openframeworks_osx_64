/**
 *  Wrapper.cpp
 *
 *  Created by Marek Bereza on 09/01/2012.
 */

#include "ofxScreenSaverWrapper.h"
#include "ofxAppMacScreenSaver.h"
#include "main.h"
#include <string>
#import <AppKit/AppKit.h>
#include <sys/time.h>

using namespace std;



ofxAppMacScreenSaver *screensaver = NULL;
string dataPath = "";

void init(const char *resPath) {
	screensaver = ofxScreensaver_main();
	dataPath = resPath;
}
void setupOpenGL(NSRect a_frame) {
    //bool isMainScreen;
    //{
      //  NSArray* listOfScreens = [NSScreen screens];
        
        //if ((listOfScreens != nil) && ([listOfScreens count] > 0))
            //return NSEqualRects([self frame], [listOfScreens objectAtIndex:0]);
    
    //NSArray* listOfScreens = [NSScreen screens];
    //NSEqualRects(a_frame, [listOfScreens objectAtIndex:1]);
        
        //return false;
    //}
    

	//NSScreen *mainScreen = [NSScreen mainScreen];
	//screensaver->modalName = string(moduleName);
	//screensaver->setupOpenGL([a_screen frame].size.width, [a_screen frame].size.height, 0, dataPath);
    NSLog(@"Wrapper :: setupOpenGL : a_frame");
    screensaver->setupOpenGL(a_frame.size.width, a_frame.size.height, 0, dataPath);
    //setup();
	//screensaver->initializeWindow();
	//screensaver->setModuleName( string(moduleName) );
	//ofAppPtr->moduleName  = string(moduleName);
	
}

void setup() {
    screensaver->setup();
    screensaver->initializeWindow();
}

void display() {
    
    //struct timeval now;
    //gettimeofday( &now, NULL );
    //return now.tv_usec/1000 + now.tv_sec*1000;
    //int ctime = (int)now.tv_usec/1000 + now.tv_sec*1000;
    
    //NSLog(@"----> Wrapper :: display : %d", ctime);
	screensaver->display();
}
void resize_cb(int w, int h) {
	screensaver->resize_cb(w, h);
}
void idle_cb() {
	screensaver->idle_cb();
}
void exit_cb() {
    if(screensaver != NULL) {
        screensaver->exit_cb();
        delete screensaver;
        screensaver = NULL;
    }
}
void keyDown_cb( int key ) {
    //string keyStr = key;
    //printf("keyStr = %s\n", keyStr.c_str());
    screensaver->keyPressed( key );
}
void keyUp_cb( int key ) {
    //string keyStr = key;
    screensaver->keyReleased( key );
}












