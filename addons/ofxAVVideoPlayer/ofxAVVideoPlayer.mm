//
//  ofxAVVideoPlayer.mm
//  FAT_64_32
//
//  Created by Nick Hardeman on 10/28/13.
//
//

#include "ofxAVVideoPlayer.h"
#include "AVFoundationVideoPlayer.h"

ofxAVVideoPlayer::ofxAVVideoPlayer() {
    videoPlayer = NULL;
	pixelsRGB = NULL;
	pixelsRGBA = NULL;
    internalGLFormat = GL_RGB;
	internalPixelFormat = OF_PIXELS_RGB;
	
    bFrameNew = false;
    bResetPixels = false;
    bResetTexture = false;
    bUpdatePixels = false;
    bUpdatePixelsToRgb = false;
    bUpdateTexture = false;
    bTextureHack = false;
    bTextureCacheSupported = false;
}

ofxAVVideoPlayer::~ofxAVVideoPlayer() {
    if(videoPlayer != NULL) {
        [(AVFoundationVideoPlayer *)videoPlayer release];
        videoPlayer = NULL;
    }
}


//----------------------------------------
bool ofxAVVideoPlayer::loadMovie(string name) {
    if(videoPlayer == NULL) {
        videoPlayer = [[AVFoundationVideoPlayer alloc] init];
        cout << "Creating new video player" << endl;
//        [(AVFoundationVideoPlayer *)videoPlayer setWillBeUpdatedExternally:YES];
    }
    
    NSString * videoPath = [NSString stringWithUTF8String:ofToDataPath(name).c_str()];
    [(AVFoundationVideoPlayer*)videoPlayer loadWithPath:videoPath];
    
    bResetPixels    = true;
    bResetTexture   = true;
    bUpdatePixels   = false;
    bUpdatePixelsToRgb = true;
    bUpdateTexture  = true;
    
    return true;
}

//----------------------------------------
void ofxAVVideoPlayer::close() {
    if(videoPlayer != NULL) {
        [(AVFoundationVideoPlayer *)videoPlayer unloadVideo];
    }
}

//----------------------------------------
void ofxAVVideoPlayer::update() {
    bFrameNew = false; // default.
    
    if(!isLoaded()) {
        return;
    }
    
    [(AVFoundationVideoPlayer *)videoPlayer update];
    bFrameNew = [(AVFoundationVideoPlayer *)videoPlayer isFrameNew];
    
    if(bFrameNew) {
        bUpdateTexture = true;
        getTexture();
        bUpdateTexture = false;
        bUpdatePixels = true;
    }
}

//----------------------------------------
void ofxAVVideoPlayer::draw(float x, float y, float w, float h) {
    getTexture()->draw( x, y, w, h );
}

//----------------------------------------
void ofxAVVideoPlayer::draw(float x, float y) {
    draw( x, y, getWidth(), getHeight() );
}

//----------------------------------------
bool ofxAVVideoPlayer::setPixelFormat(ofPixelFormat _internalPixelFormat) {
	if(_internalPixelFormat == OF_PIXELS_RGB) {
		internalPixelFormat = _internalPixelFormat;
		internalGLFormat = GL_RGB;
		return true;
    } else if(_internalPixelFormat == OF_PIXELS_RGBA) {
		internalPixelFormat = _internalPixelFormat;
		internalGLFormat = GL_RGBA;
		return true;
    } else if(_internalPixelFormat == OF_PIXELS_BGRA) {
		internalPixelFormat = _internalPixelFormat;
		internalGLFormat = GL_BGRA;
		return true;
    }
	return false;
}


//---------------------------------------------------------------------------
ofPixelFormat ofxAVVideoPlayer::getPixelFormat(){
	return internalPixelFormat;
}

//----------------------------------------
unsigned char * ofxAVVideoPlayer::getPixels() {
	if(isLoaded()) {
        if(!bUpdatePixels) { // if pixels have not changed, return the already calculated pixels.
            if(internalGLFormat == GL_RGB) {
                updatePixelsToRGB();
                return pixelsRGB;
            }  else if(internalGLFormat == GL_RGBA || internalGLFormat == GL_BGRA) {
                return pixelsRGBA;
            }
        }
        
		CGImageRef currentFrameRef;
		
		NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
		
		CVPixelBufferRef imageBuffer = [(AVFoundationVideoPlayer *)videoPlayer getCurrentBufferRef];
        
		/*Lock the image buffer*/
		CVPixelBufferLockBaseAddress(imageBuffer,0);
		
		/*Get information about the image*/
		uint8_t *baseAddress	= (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
		size_t bytesPerRow		= CVPixelBufferGetBytesPerRow(imageBuffer);
		size_t width			= CVPixelBufferGetWidth(imageBuffer);
		size_t height			= CVPixelBufferGetHeight(imageBuffer);
		
		/*Create a CGImageRef from the CVImageBufferRef*/
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		CGContextRef newContext = CGBitmapContextCreate(baseAddress,
                                                        width,
                                                        height,
                                                        8,
                                                        bytesPerRow,
                                                        colorSpace,
                                                        kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
		CGImageRef newImage	= CGBitmapContextCreateImage(newContext);
		
		currentFrameRef = CGImageCreateCopy(newImage);
		
		/*We release some components*/
		CGContextRelease(newContext);
		CGColorSpaceRelease(colorSpace);
		
		/*We relase the CGImageRef*/
		CGImageRelease(newImage);
		
		/*We unlock the  image buffer*/
		CVPixelBufferUnlockBaseAddress(imageBuffer,0);
		
		if(bResetPixels) {
            
            if(pixelsRGBA != NULL) {
                free(pixelsRGBA);
                pixelsRGBA = NULL;
            }
            
            if(pixelsRGB != NULL) {
                free(pixelsRGB);
                pixelsRGB = NULL;
            }
            
            pixelsRGBA = (GLubyte *) malloc(width * height * 4);
            pixelsRGB  = (GLubyte *) malloc(width * height * 3);
            
            bResetPixels = false;
		}
		
		[pool drain];
		
        CGContextRef spriteContext;
        spriteContext = CGBitmapContextCreate(pixelsRGBA,
                                              width,
                                              height,
                                              CGImageGetBitsPerComponent(currentFrameRef),
                                              width * 4,
                                              CGImageGetColorSpace(currentFrameRef),
                                              kCGImageAlphaPremultipliedLast);
        
        CGContextDrawImage(spriteContext,
                           CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height),
                           currentFrameRef);
        
        CGContextRelease(spriteContext);
        
        if(internalGLFormat == GL_RGB) {
            updatePixelsToRGB();
        } else if(internalGLFormat == GL_RGBA || internalGLFormat == GL_BGRA) {
            // pixels are already 4 channel.
            // return pixelsRaw instead of pixels (further down).
        }
        
        CGImageRelease(currentFrameRef);
		
        bUpdatePixels = false;
        
        if(internalGLFormat == GL_RGB) {
            return pixelsRGB;
        }  else if(internalGLFormat == GL_RGBA || internalGLFormat == GL_BGRA) {
            return pixelsRGBA;
        }
        
        return NULL;
	}
	
	return NULL;
}

void ofxAVVideoPlayer::updatePixelsToRGB() {
    if(!bUpdatePixelsToRgb) {
        return;
    }
    
    int width = [(AVFoundationVideoPlayer *)videoPlayer getWidth];
    int height = [(AVFoundationVideoPlayer *)videoPlayer getHeight];
    
    unsigned int *isrc4 = (unsigned int *)pixelsRGBA;
    unsigned int *idst3 = (unsigned int *)pixelsRGB;
    unsigned int *ilast4 = &isrc4[width*height-1];
    while (isrc4 < ilast4){
        *(idst3++) = *(isrc4++);
        idst3 = (unsigned int *) (((unsigned char *) idst3) - 1);
    }
    
    bUpdatePixelsToRgb = false;
}

//----------------------------------------
ofPixelsRef ofxAVVideoPlayer::getPixelsRef() {
    static ofPixels dummy;
    return dummy;
}

//----------------------------------------
ofTexture * ofxAVVideoPlayer::getTexture() {
    
    if(!isLoaded()) {
        return &videoTexture;
    }
    
    if(!bUpdateTexture) {
        return &videoTexture;
    }
    
    if(!videoTexture.isAllocated()) {
        cout << "allocating the video texture " << endl;
        videoTexture.allocate( getWidth(), getHeight(), GL_RGBA );
    }
    
    
    CVPixelBufferRef buffer = [((AVFoundationVideoPlayer *)videoPlayer) getCurrentBufferRef];
    // Lock the image buffer
    CVPixelBufferLockBaseAddress(buffer, 0);
    
    // Get information of the image
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(buffer);
    size_t width    = CVPixelBufferGetWidth(buffer);
    size_t height   = CVPixelBufferGetHeight(buffer);
    
    // Fill the texture
    glBindTexture(GL_TEXTURE_2D, videoTexture.getTextureData().textureID );
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_BGRA_EXT, GL_UNSIGNED_BYTE, baseAddress);
    
    CVPixelBufferUnlockBaseAddress(buffer, 0);
    
    return &videoTexture;
}

//----------------------------------------
float ofxAVVideoPlayer::getWidth() {
    if(videoPlayer == NULL) {
        return 0;
    }
    return [((AVFoundationVideoPlayer *)videoPlayer) getWidth];
}

//----------------------------------------
float ofxAVVideoPlayer::getHeight() {
    if(videoPlayer == NULL) {
        return 0;
    }
    return [((AVFoundationVideoPlayer *)videoPlayer) getHeight];
}

//----------------------------------------
void ofxAVVideoPlayer::play() {
    if(videoPlayer == NULL) {
        ofLogWarning("ofiPhoneVideoPlayer") << "play(): video not loaded";
        return;
    }
    
	[(AVFoundationVideoPlayer *)videoPlayer play];
}

//----------------------------------------
void ofxAVVideoPlayer::stop() {
    if(videoPlayer == NULL) {
        return;
    }
    
    [(AVFoundationVideoPlayer *)videoPlayer pause];
    [(AVFoundationVideoPlayer *)videoPlayer seekToStart];
}

//----------------------------------------
void ofxAVVideoPlayer::setPaused( bool bPause ) {
    if(videoPlayer == NULL) return;
    if(bPause) {
        [(AVFoundationVideoPlayer *)videoPlayer pause];
    } else {
        [(AVFoundationVideoPlayer *)videoPlayer play];
    }
}

bool ofxAVVideoPlayer::isPaused() {
    if(videoPlayer == NULL) return true;
    return [(AVFoundationVideoPlayer *)videoPlayer isPaused];
}

//----------------------------------------
bool ofxAVVideoPlayer::isFrameNew() {
	if(videoPlayer != NULL) {
		return bFrameNew;
	}
	return false;
}

//----------------------------------------
bool ofxAVVideoPlayer::isLoaded() {
    if(videoPlayer == NULL) return false;
    return [((AVFoundationVideoPlayer *)videoPlayer) isReady];
}

//----------------------------------------
bool ofxAVVideoPlayer::isPlaying() {
    if(videoPlayer == NULL) return false;
    return [((AVFoundationVideoPlayer *)videoPlayer) isPlaying];
}

//----------------------------------------
float ofxAVVideoPlayer::getPosition() {
    if(videoPlayer == NULL) return 0.f;
    return [((AVFoundationVideoPlayer *)videoPlayer) getPosition];
}

//----------------------------------------
void ofxAVVideoPlayer::setPosition( float aPct ) {
    if(videoPlayer == NULL) return;
    [((AVFoundationVideoPlayer *)videoPlayer) setPosition:aPct];
}

//----------------------------------------
float ofxAVVideoPlayer::getDuration() {
    if(videoPlayer == NULL) return 0.f;
    return [((AVFoundationVideoPlayer *)videoPlayer) getDurationInSeconds];
}

//----------------------------------------
bool ofxAVVideoPlayer::getIsMovieDone() {
    if(!isLoaded()) return false;
    return [((AVFoundationVideoPlayer *)videoPlayer) isFinished];
}

//----------------------------------------
void ofxAVVideoPlayer::setLoopState(ofLoopType state) {
    if(videoPlayer == NULL) return false;
    if(state == OF_LOOP_NONE) {
        [((AVFoundationVideoPlayer *)videoPlayer) setLoop:false];
    } else if(state == OF_LOOP_NORMAL) {
        [((AVFoundationVideoPlayer *)videoPlayer) setLoop:true];
    } else {
        ofLogWarning("ofxAvVideoPlayer :: loop state currently not supported");
    }
}

//----------------------------------------
ofLoopType ofxAVVideoPlayer::getLoopState() {
    if(videoPlayer == NULL) return OF_LOOP_NONE;
    bool isLooping = [((AVFoundationVideoPlayer *)videoPlayer) getLoop];
    if(isLooping) {
        return OF_LOOP_NORMAL;
    }
    return OF_LOOP_NONE;
}

//----------------------------------------
float ofxAVVideoPlayer::getSpeed() {
    if(videoPlayer == NULL) return 1.f;
    return [((AVFoundationVideoPlayer *)videoPlayer) getSpeed];
}

//----------------------------------------
void ofxAVVideoPlayer::setSpeed(float speed) {
    if(videoPlayer == NULL) return;
    [((AVFoundationVideoPlayer *)videoPlayer) setSpeed:speed];
}
















