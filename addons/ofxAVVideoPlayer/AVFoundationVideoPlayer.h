//
//  ofxAVVideoPlayer.h
//  FAT_64_32
//
//  Created by Nick Hardeman on 10/28/13.
//
//

#pragma once
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class AVPlayer;
@class AVPlayerItem;
@class AVPlayerItemVideoOutput;

//---------------------------------------------------------- video player delegate.
//@protocol AVFoundationVideoPlayerDelegate <NSObject>
//- (void)playerReady;
//- (void)playerDidProgress;
//- (void)playerDidFinishPlayingVideo;
//@end

//---------------------------------------------------------- video player.
@interface AVFoundationVideoPlayer : NSObject {
//    id<AVFoundationVideoPlayerDelegate> delegate;
    AVPlayer *player;
    AVPlayerItem *playerItem;
    AVPlayerItemVideoOutput* output;
    
    CVPixelBufferRef buffer;
    
    BOOL bLoop;
    float videoWidth;
    float videoHeight;
    CMTime currentTime;
    BOOL bNewFrame;
    float framerate;
    float speed;
    
    BOOL bPlaying;
    BOOL bPlayOnLoad;
    BOOL bFinished;
    BOOL bUpdateFirstFrame;
    BOOL bReady;
}

@property (nonatomic, retain) AVPlayer * player;
@property (nonatomic, retain) AVPlayerItem * playerItem;
@property (nonatomic, assign)AVPlayerItemVideoOutput* output;

- (BOOL)loadWithFile:(NSString*)file;
- (BOOL)loadWithPath:(NSString*)path;
- (BOOL)loadWithURL:(NSURL*)url;
- (void)unloadVideo;

- (void)update;

- (CVPixelBufferRef)getCurrentBufferRef;

- (BOOL)isFrameNew;
- (BOOL)isReady;
- (BOOL)isPlaying;
- (BOOL)isFinished;

- (void)play;
- (void)pause;
- (void)togglePlayPause;
- (BOOL)isPaused;

- (float)getVolume;
- (void)setVolume:(float)volume;

- (void)setLoop:(BOOL)loop;
- (BOOL)getLoop;

- (float)getWidth;
- (float)getHeight;

- (CMTime)getDuration;
- (double)getDurationInSeconds;
- (void)seekToStart;
- (CMTime)getCurrentTime;
- (float)getCurrentTimeSeconds;
- (void)setCurrentTime:(float)time;

- (void)setPosition:(float)position;
- (float)getPosition;

- (void)setSpeed:(float)aSpeed;
- (float)getSpeed;


@end