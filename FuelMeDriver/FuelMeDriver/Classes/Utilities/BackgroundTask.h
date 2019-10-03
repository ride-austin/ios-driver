//
//  BackgroundTask.h
//  RideDriver
//
//  Created by Tyson Bunch on 6/28/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface BackgroundTask : NSObject {
    __block dispatch_block_t expirationHandler;
    NSInteger timerInterval;
    id target;
    SEL selector;
}

@property (nonatomic, assign) UIBackgroundTaskIdentifier bgTask;
@property (nonatomic, strong) NSTimer * timer;
@property (nonatomic, strong) AVAudioPlayer *player;

- (void)startBackgroundTasks:(NSInteger)time_  target:(id)target_ selector:(SEL)selector_;
- (void)stopBackgroundTask;

@end
