//
//  BackgroundTask.m
//  RideDriver
//
//  Created by Tyson Bunch on 6/28/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "BackgroundTask.h"

#import <AVFoundation/AVFoundation.h>

void interruptionListenerCallback (void *inUserData, UInt32 interruptionState);

@implementation BackgroundTask

- (id)init {
    self = [super init];
    if (self) {
        self.bgTask = UIBackgroundTaskInvalid;
        expirationHandler =nil;
        self.timer = nil;
    }
    return self;
}

- (void)startBackgroundTasks:(NSInteger)time_  target:(id)target_ selector:(SEL)selector_ {
    timerInterval = time_;
    target = target_;
    selector = selector_;
    
    [self initBackgroudTask];
    //minimum 600 sec
    [[UIApplication sharedApplication] setKeepAliveTimeout:600 handler:^{
        [self initBackgroudTask];
    }];
    
}

- (void)initBackgroudTask {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        if([self running]) {
            [self stopAudio];
        }
        
        while([self running]) {
            [NSThread sleepForTimeInterval:10]; //wait for finish
        }
        [self playAudio];
    });
}

- (void)audioInterrupted:(NSNotification*)notification {
    NSDictionary *interuptionDict = notification.userInfo;
    NSNumber *interuptionType = [interuptionDict valueForKey:AVAudioSessionInterruptionTypeKey];
    if([interuptionType intValue] == 1) {
        [self initBackgroudTask];
    }
}

void interruptionListenerCallback (void *inUserData, UInt32 interruptionState) {
    if (interruptionState == kAudioSessionBeginInterruption) {
    }
}

- (void)playAudio {
    UIApplication * app = [UIApplication sharedApplication];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioInterrupted:) name:AVAudioSessionInterruptionNotification object:nil];

    __weak BackgroundTask *weakSelf = self;
    expirationHandler = ^{
        [app endBackgroundTask:weakSelf.bgTask];
        weakSelf.bgTask = UIBackgroundTaskInvalid;
        [weakSelf.timer invalidate];
        [weakSelf.player stop];
    };
    
    self.bgTask = [app beginBackgroundTaskWithExpirationHandler:expirationHandler];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSURL *soundFileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                             pathForResource:@"Silent"
                                             ofType:@"wav"]];
        NSError * error;
    
        // We must use AVAudioSessionCategoryAmbient instead of AVAudioSessionCategoryPlayback  to avoid crashes on background RA-3419
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
        [[AVAudioSession sharedInstance] setActive: YES error: &error];
        
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:&error];
        self.player.volume = 0.01;
        self.player.numberOfLoops = -1; //Infinite
        [self.player prepareToPlay];
        [self.player play];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:timerInterval target:target selector:selector userInfo:nil repeats:YES];
        
    });
}

- (void)stopAudio {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionInterruptionNotification object:nil];
    
    if(self.timer != nil && [self.timer isValid]) {
        [self.timer invalidate];
    }
    
    if(self.player != nil && [self.player isPlaying]) {
        [self.player stop];
    }
    
    if(self.bgTask != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:self.bgTask];
        self.bgTask = UIBackgroundTaskInvalid;
    }
}

- (BOOL)running {
    if(self.bgTask == UIBackgroundTaskInvalid) {
        return FALSE;
    }
    return TRUE;
}

- (void)stopBackgroundTask {
    [self stopAudio];
}

@end
