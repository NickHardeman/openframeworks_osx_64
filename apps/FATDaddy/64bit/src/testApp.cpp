#include "testApp.h"

//--------------------------------------------------------------
void testApp::setup() {
    ofDisableArbTex();
    player.loadMovie("fingers.mov");
    player.play();
    player.setLoopState( OF_LOOP_NORMAL );
    player.setSpeed( 2.f );
    
//    grabber.initGrabber(640, 480);
    cout << "testApp :: setup : dims = " << player.getWidth() << " x " << player.getHeight() << endl;
    ofImage img;
    img.loadImage("http://www.openframeworks.cc/of_inverted.png");
    
    players.resize(30);
    for(int i = 0; i < 30; i++ ) {
        players[i].loadMovie("fingers.mov");
        players[i].play();
        players[i].setLoopState( OF_LOOP_NORMAL );
        players[i].setSpeed( ofMap(i, 0, 29, .5, 2, true ));
    }
}

//--------------------------------------------------------------
void testApp::update() {
//    player.update();
    
    cout << "framerate: " << ofGetFrameRate() << endl;
    
//    if(player.isLoaded() && player.isFrameNew()) {
//        cout << "Setting the pixels " << ofGetElapsedTimef() << endl;
//        unsigned char * pixels = player.getPixels();
//        
//        if(!outImage.isAllocated()) {
//            outImage.allocate( player.getWidth(), player.getHeight(), OF_IMAGE_COLOR );
//        }
//        
//        for(int x = 0; x < player.getWidth(); x++ ) {
//            for(int y = 0; y < player.getHeight(); y++ ) {
//                int pixIndex = (y * player.getWidth() + x) * 3;
//                ofColor tcolor;
//                tcolor.r = 255 - pixels[pixIndex+0];
//                tcolor.g = 255 - pixels[pixIndex+1];
//                tcolor.b = 255 - pixels[pixIndex+2];
//                outImage.setColor(x, y, tcolor);
//            }
//        }
//        outImage.update();
//    }
    
    
//    player.setSpeed( 5.f );
    if(player.getIsMovieDone()) {
        cout << "the movie is done " << endl;
    }
    
    for(int i = 0; i < players.size(); i++ ) {
        players[i].update();
    }
}

//--------------------------------------------------------------
void testApp::draw() {
    ofSetColor(255, 255, 255);
    
    for(int i = 0; i < players.size(); i++ ) {
        players[i].draw( (i % 6) * (players[i].getWidth()*.75), floor(i / 6) * (players[i].getHeight()*.75),
                        players[i].getWidth()*.75,
                        players[i].getHeight()*.75);
    }
    
    if(player.isLoaded()) {
//        player.draw( 620, 20 );
    }
//    outImage.draw(20, 20 );
}

//--------------------------------------------------------------
void testApp::keyPressed(int key){

}

//--------------------------------------------------------------
void testApp::keyReleased(int key){

}

//--------------------------------------------------------------
void testApp::mouseMoved(int x, int y){

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