#include "testApp.h"

//--------------------------------------------------------------
void testApp::setup()
{
    ofSetVerticalSync(true);
    ofBackground(0);
    
    video.loadMovie("test.mov");
    video.play();
    video.setLoopState(OF_LOOP_NORMAL);
}

//--------------------------------------------------------------
void testApp::update()
{
    video.update();
    if (video.isLoaded() && !image.isAllocated()) {
        image.allocate(video.getWidth(), video.getHeight(), OF_IMAGE_COLOR);
    }
    if (video.isFrameNew()) {
        image.setFromPixels(video.getPixelsRef());
    }
}

//--------------------------------------------------------------
void testApp::draw()
{
    video.draw(0, 0);
	if(image.bAllocated()){
		image.draw(video.getWidth(), 0);
    }
	
    // Draw a timeline at the bottom of the screen.
    ofNoFill();
    ofSetColor(255);
    ofRect(0, ofGetHeight(), ofGetWidth(), -100);
    float playheadX = video.getPosition() * ofGetWidth();
    ofLine(playheadX, ofGetHeight() - 100, playheadX, ofGetHeight());
    ofDrawBitmapStringHighlight(ofToString(video.getCurrentTime()) + " / " + ofToString(video.getDuration()), playheadX + 10, ofGetHeight() - 80);
    ofDrawBitmapStringHighlight(ofToString(video.getCurrentFrame()) + " / " + ofToString(video.getTotalNumFrames()), playheadX + 10, ofGetHeight() - 10);
    
    ofDrawBitmapStringHighlight("Rate: " + ofToString(video.getSpeed(), 2) + "\n" +
                                "Time: " + ofToString(video.getCurrentTime(), 3) + " / " + ofToString(video.getDuration(), 3) + "\n" +
                                "Frames: " + ofToString(video.getCurrentFrame()) + " / " + ofToString(video.getTotalNumFrames()) + "\n" +
                                "Position: " + ofToString(video.getPosition() * 100, 1) + "%" + "\n" +
                                "Volume: " + ofToString(video.getVolume(), 2) + "\n" +
                                "\n" +
                                "[a]/[s]: Play / Stop \n" +
                                "[space]: Pause \n" +
                                "[up]/[down]: Adjust Rate \n" +
                                "[mouse y]: Volume",
                                10, 20);
}

//--------------------------------------------------------------
void testApp::keyPressed(int key)
{
    switch (key) {
        case ' ':
            if (video.isPaused()) video.setPaused(false);
            else video.setPaused(true);
            break;
            
        case 'a':
            video.play();
            break;
            
        case 's':
            video.stop();
            break;
            
        case OF_KEY_UP:
            video.setSpeed(video.getSpeed() * 1.1);
            break;
            
        case OF_KEY_DOWN:
            video.setSpeed(video.getSpeed() * 0.9);
            break;
            
        default:
            break;
    }
}

//--------------------------------------------------------------
void testApp::keyReleased(int key){

}

//--------------------------------------------------------------
void testApp::mouseMoved(int x, int y)
{
    video.setVolume(ofMap(y, 0, ofGetHeight(), 1.0, 0.0, true));
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

//--------------------------------------------------------------
void testApp::windowResized(int w, int h){

}

//--------------------------------------------------------------
void testApp::gotMessage(ofMessage msg){

}

//--------------------------------------------------------------
void testApp::dragEvent(ofDragInfo dragInfo){ 

}
