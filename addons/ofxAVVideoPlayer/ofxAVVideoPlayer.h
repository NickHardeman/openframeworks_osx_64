//
//  ofxAVVideoPlayer.h
//  FAT_64_32
//
//  Created by Nick Hardeman on 10/28/13.
//
//

#pragma once
#include "ofPixels.h"
#include "ofBaseTypes.h"
#include "ofTexture.h"
#include "ofVideoPlayer.h"

//@class AVFoundationVideoPlayer;

class ofxAVVideoPlayer : public ofBaseVideoPlayer {
public:
    ofxAVVideoPlayer();
    ~ofxAVVideoPlayer();
    
    bool loadMovie( string name );
    void close();
    
    void update();
    void draw(float x, float y, float w, float h);
    void draw(float x, float y);
    
    bool			setPixelFormat(ofPixelFormat pixelFormat);
	ofPixelFormat 	getPixelFormat();
	
    void play();
    void stop();
    void setPaused(bool bPause);
	
    bool isFrameNew();
    unsigned char * getPixels();
    ofPixelsRef	getPixelsRef();
    ofTexture *	getTexture();
    
    float getWidth();
    float getHeight();
	
    bool isPaused();
    bool isLoaded();
    bool isPlaying();
//
    float getPosition();
    void setPosition(float pct);
    float getDuration();
    
    bool getIsMovieDone();
//
//
//    void setVolume(float volume); // 0..1
    void setLoopState(ofLoopType state);
    ofLoopType getLoopState();
    
    float getSpeed();
    void setSpeed(float speed);
//    void setFrame(int frame);  // frame 0 = first frame...
//	
//    int	getCurrentFrame();
//    int	getTotalNumFrames();
//    ofLoopType	getLoopState();
//	
//    void firstFrame();
//    void nextFrame();
//    void previousFrame();
//    
//	void * getAVFoundationVideoPlayer();
    
protected:
    
    void updatePixelsToRGB();
	
	void* videoPlayer; // super hack to forward declare an objective c class inside a header file that can only handle c classes.
	
    bool bFrameNew;
    bool bResetPixels;
    bool bResetTexture;
    bool bUpdatePixels;
    bool bUpdatePixelsToRgb;
    bool bUpdateTexture;
    bool bTextureCacheSupported;
    bool bTextureHack;
	
	GLubyte * pixelsRGB;
    GLubyte * pixelsRGBA;
    GLint internalGLFormat;
	ofPixelFormat internalPixelFormat;
	ofTexture videoTexture;
}; 
