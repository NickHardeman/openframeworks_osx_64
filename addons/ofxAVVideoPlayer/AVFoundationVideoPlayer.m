//
//  ofxAVVideoPlayer.mm
//  FAT_64_32
//
//  Created by Nick Hardeman on 10/28/13.
//
//

#include "AVFoundationVideoPlayer.h"

static void *AVSPPlayerItemStatusContext    = &AVSPPlayerItemStatusContext;
static void *AVSPPlayerRateContext          = &AVSPPlayerRateContext;
static void *AVSPPlayerLayerReadyForDisplay = &AVSPPlayerLayerReadyForDisplay;

@implementation AVFoundationVideoPlayer

@synthesize player;
@synthesize playerItem;
@synthesize output;

- (id)init {
    self = [super init];
    if(self) {
        self.player     = nil;
        self.playerItem = nil;
        self.output     = nil;
        
        buffer          = nil;
        
        bLoop           = NO;
        videoWidth      = 0.f;
        videoHeight     = 0.f;
        
        currentTime     = kCMTimeZero;
        bNewFrame       = NO;
        
        framerate       = 0;
        bPlayOnLoad     = NO;
        
        bFinished       = NO;
        bPlaying        = NO;
        bUpdateFirstFrame   = NO;
        bReady          = NO;
        [self setSpeed:1.f];
    }
    return self;
}

- (void)dealloc {
    [self unloadVideo];
	
	[super dealloc];
}

//---------------------------------------------------------- load / unload.
- (BOOL)loadWithFile:(NSString*)file {
    NSArray * fileSplit = [file componentsSeparatedByString:@"."];
    NSURL * fileURL = [[NSBundle mainBundle] URLForResource:[fileSplit objectAtIndex:0]
                                              withExtension:[fileSplit objectAtIndex:1]];
    
	return [self loadWithURL:fileURL];
}

- (BOOL)loadWithPath:(NSString*)path {
    NSURL * fileURL = [NSURL fileURLWithPath:path];
	return [self loadWithURL:fileURL];
}

- (BOOL)loadWithURL:(NSURL*)url {
    
    [self unloadVideo];
    
    AVURLAsset *asset = [ AVAsset assetWithURL:url ];
	NSArray *assetKeysToLoadAndTest = [NSArray arrayWithObjects:@"playable", @"hasProtectedContent", @"tracks", @"duration", nil];
	[asset loadValuesAsynchronouslyForKeys:assetKeysToLoadAndTest completionHandler:^(void) {
		// The asset invokes its completion handler on an arbitrary queue when loading is complete.
		// Because we want to access our AVPlayer in our ensuing set-up, we must dispatch our handler to the main queue.
		dispatch_async(dispatch_get_main_queue(), ^(void) {
			[self setUpPlaybackOfAsset:asset withKeys:assetKeysToLoadAndTest];
		});
	}];
}

- (void)setUpPlaybackOfAsset:(AVAsset *)asset withKeys:(NSArray *)keys {
	// This method is called when the AVAsset for our URL has completing the loading of the values of the specified array of keys.
	// We set up playback of the asset here.
	
	// First test whether the values of each of the keys we need have been successfully loaded.
	for (NSString *key in keys) {
		NSError *error = nil;
		if ([asset statusOfValueForKey:key error:&error] == AVKeyValueStatusFailed) {
//			[self stopLoadingAnimationAndHandleError:error];
            NSLog(@"AVFoundationVideoPlayer :: can not play this asset error:%@", [error localizedDescription] );
			return;
		}
	}
	
	if (![asset isPlayable] || [asset hasProtectedContent]) {
		// We can't play this asset. Show the "Unplayable Asset" label.
        NSLog(@"AVFoundationVideoPlayer :: can not play this asset!");
		return;
	}
	
	// We can play this asset.
	// Set up an AVPlayerLayer according to whether the asset contains video.
	if ([[asset tracksWithMediaType:AVMediaTypeVideo] count] != 0) {
        
        NSArray * videoTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
        if([videoTracks count] > 0) {
            AVAssetTrack * track = [videoTracks objectAtIndex:0];
            framerate = track.nominalFrameRate;
            CGSize dims = [track naturalSize];
//            NSLog(@"track dims = %f x %f", dims.width, dims.height );
            videoWidth  = dims.width;
            videoHeight = dims.height;
        }
	} else {
		// This asset has no video tracks. Show the "No Video" label.
        NSLog(@"AVFoundationVideoPlayer :: this asset has no video tracks");
        return;
	}
	
	// Create a new AVPlayerItem and make it our player's current item.
    self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    // http://stackoverflow.com/questions/16873119/playing-video-and-retrieving-pixel-buffer-with-ios5
    NSDictionary* settings = @{ (id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInt:kCVPixelFormatType_32BGRA] };
    self.output = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:settings];
    [self.playerItem addOutput:self.output];
    
    NSNotificationCenter * notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(playerItemDidReachEnd)
                               name:AVPlayerItemDidPlayToEndTimeNotification
                             object:self.playerItem];
    
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    
//    [self addObserver:self forKeyPath:@"player.rate" options:NSKeyValueObservingOptionNew context:AVSPPlayerRateContext];
//	[self addObserver:self forKeyPath:@"player.currentItem.status" options:NSKeyValueObservingOptionNew context:AVSPPlayerItemStatusContext];
    [self.player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew context:AVSPPlayerRateContext];
    [self.player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:AVSPPlayerItemStatusContext];
//    NSLog(@"AVFoundationVideoPlayer :: dims = %d x %d", videoWidth, videoHeight );
	
//	[self setTimeObserverToken:[[self player] addPeriodicTimeObserverForInterval:CMTimeMake(1, 10) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
//		[[self timeSlider] setDoubleValue:CMTimeGetSeconds(time)];
//	}]];
	
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (context == AVSPPlayerItemStatusContext) {
		AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
		BOOL enable = NO;
		switch (status) {
			case AVPlayerItemStatusUnknown:
				break;
			case AVPlayerItemStatusReadyToPlay:
                NSLog(@"AVPlayerItemStatusReadyToPlay");
				enable = YES;
				break;
			case AVPlayerItemStatusFailed:
                NSLog(@"AVFoundationVideoPlayer :: observeValueForKeyPath : Item Status FAIL!");
				break;
		}
        if(enable) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(bPlayOnLoad) {
                    bReady = YES;
                    NSLog(@"Playing on load isReady = %i", [self isReady]);
                    bUpdateFirstFrame   = YES;
                    [self update];
                    [self play];
                    bPlayOnLoad = NO;
                }
            });
        }
		
	} else if (context == AVSPPlayerRateContext) {
		float rate = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
		if (rate != 1.f) {
//			[[self playPauseButton] setTitle:@"Play"];
		} else {
//			[[self playPauseButton] setTitle:@"Pause"];
		}
	} else if (context == AVSPPlayerLayerReadyForDisplay) {
		if ([[change objectForKey:NSKeyValueChangeNewKey] boolValue] == YES) {
            
		}
	} else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)unloadVideo {
    bReady      = NO;
    bNewFrame   = NO;
    bFinished   = NO;
    currentTime = kCMTimeZero;
    
    videoWidth  = 0;
    videoHeight = 0;
    bPlaying    = NO;
    bPlayOnLoad = NO;
    
    if(self.player != nil) {
        [self.player removeObserver:self forKeyPath:@"rate"];
        [self.player removeObserver:self forKeyPath:@"status"];
        
        [self.player release];
        self.player = nil;
    }
    
    if(self.playerItem != nil) {
        NSNotificationCenter * notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter removeObserver:self
                                      name:AVPlayerItemDidPlayToEndTimeNotification
                                    object:self.playerItem];
        [self.playerItem release];
        self.playerItem = nil;
    }
    
    if(self.output != nil) {
        [self.output release];
        self.output = nil;
    }
    
}

- (void)playerItemDidReachEnd {
//    NSLog(@"AVFoundationPlayer :: we reached the end of the video");
    bFinished = YES;
    bPlaying = NO;
//    [self.delegate playerDidFinishPlayingVideo];
    if(bLoop) {
        bFinished = NO;
        [self seekToStart];
        [self play];
    }
}

- (void)update {
    if( ![self isReady] || [self isFinished]) {
        bNewFrame = NO;
        return;
    }
    
    
    CMTime time = [self.player currentTime];
    if(bUpdateFirstFrame) {
        NSLog(@"Hit the first frame");
        
    } else if(CMTimeCompare(time, currentTime) == 0 ) {
        bNewFrame = NO;
        return; // no progress made.
    }
    currentTime = time;
    
//    NSLog(@"AVFoundationVIdeoPlayer :: update : %f", [self getCurrentTimeSeconds]);
    
    if ([[self output] hasNewPixelBufferForItemTime:currentTime] || bUpdateFirstFrame ) {
//        CVPixelBufferRef buffer = [[self output] copyPixelBufferForItemTime:currentTime itemTimeForDisplay:nil];
        
//        NSLog(@"AVFoundationVIdeoPlayer :: update : ");
        
        if(buffer != nil) {
            CVBufferRelease(buffer);
            buffer = nil;
        }
        
//        CMSampleBufferRef bufferTemp = [self.output copyNextSampleBuffer];
        
        buffer = [[self output] copyPixelBufferForItemTime:currentTime itemTimeForDisplay:nil];
        
        // Lock the image buffer
//        CVPixelBufferLockBaseAddress(buffer, 0);
        
        // Get information of the image
//        uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(buffer);
//        size_t width    = CVPixelBufferGetWidth(buffer);
//        size_t height   = CVPixelBufferGetHeight(buffer);
        
//        videoWidth      = (float)width;
//        videoHeight     = (float)height;
        
        // Fill the texture
//        glBindTexture(GL_TEXTURE_2D, texture);
//        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_BGRA_EXT, GL_UNSIGNED_BYTE, baseAddress);
        
        // Unlock the image buffer
//        CVPixelBufferUnlockBaseAddress(buffer, 0);
        //CFRelease(sampleBuffer);
//        CVBufferRelease(buffer);
        bNewFrame = YES;
        
    } else {
        bNewFrame = NO;
    }
    bUpdateFirstFrame = NO;
}

- (CVPixelBufferRef)getCurrentBufferRef {
    return buffer;
}

- (BOOL)isFrameNew {
    if(![self isReady]) return NO;
    return bNewFrame;
}

- (BOOL)isReady {
    if(self.player == nil) return NO;
    if(self.playerItem == nil) return NO;
//    return [self.playerItem status] == AVPlayerItemStatusReadyToPlay;
    return bReady;
}

- (BOOL)isPlaying {
    if(![self isReady]) {
        return bPlayOnLoad;
    }
    return bPlaying;
}

- (BOOL)isPaused {
    if( ![self isReady] ) {
        return !bPlayOnLoad;
    }
    return ![self isPlaying];
}

- (BOOL)isFinished {
    return bFinished;
}

//---------------------------------------------------------- play / pause.
- (void)play {
    if( ![self isReady] ) {
        bPlayOnLoad = YES;
        return;
    }
    if(![self isPlaying]) {
        if([self isFinished]) {
            [self seekToStart];
            bFinished = NO;
        }
        [self.player play];
        [self.player setRate:speed];
    }
    
    bPlaying = YES;
}

- (void)pause {
    if( ![self isReady] ) {
        bPlayOnLoad = NO;
        return;
    }
    [[self player] pause];
    bPlaying = NO;
}

- (void)togglePlayPause {
    if( ![self isReady] ) {
        bPlayOnLoad = !bPlayOnLoad;
        return;
    }
    if([self isPlaying]) {
        [self pause];
    } else {
        [self play];
    }
}

//---------------------------------------------------------- volume.
- (float)getVolume {
    if( ![self isReady] ) return 1.f;
	return [[self player] volume];
}

- (void)setVolume:(float)volume {
    if( ![self isReady] ) return;
	[[self player] setVolume:volume];
}

- (void)setLoop:(BOOL)loop {
    bLoop = loop;
}

- (BOOL)getLoop {
    return bLoop;
}

- (float)getWidth {
    return videoWidth;
}

- (float)getHeight {
    return videoHeight;
}

//---------------------------------------------------------- time.
- (CMTime)getDuration {
    if( ![self isReady] ) return kCMTimeZero;
	if ([self.playerItem status] == AVPlayerItemStatusReadyToPlay) {
		return [[self.playerItem asset] duration];
    }
    return kCMTimeZero;
}

- (double)getDurationInSeconds {
    CMTimeGetSeconds( [self getDuration] );
}

- (void)seekToStart {
	[self setCurrentTime:0.f];
}

- (CMTime)getCurrentTime {
    return currentTime;
}

- (float)getCurrentTimeSeconds {
    if( ![self isReady] ) return 0.f;
	return CMTimeGetSeconds([[self player] currentTime]);
}

- (void)setCurrentTime:(float)time {
    bFinished = NO;
    if(self.player == nil) return;
    [[self player] seekToTime:CMTimeMakeWithSeconds(time, 1) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero ];
}

- (float)getPosition {
    if(![self isReady]) return 0.f;
    return [self getCurrentTimeSeconds] / [self getDurationInSeconds];
}

- (void)setPosition:(float)position {
    double time = [self getDurationInSeconds] * position;
    [ self setCurrentTime:time ];
}

- (void)setSpeed:(float)aSpeed {
    speed = aSpeed;
}

- (float)getSpeed {
    return speed;
}


@end

