//
//  SoundManager.h
//  RideDriver
//
//  Created by Carlos Alcala on 12/13/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <Foundation/Foundation.h>

#import "SoundManagerDefines.h"

@interface SoundManager : NSObject

@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, assign) SystemSound sound;
@property (nonatomic, assign) PlayerType playerType;
@property (nonatomic, assign) OutputPort port;

+ (SoundManager*)sharedManager;

- (void)updateAudioPort:(OutputPort)port;
- (void)playSound:(SystemSound)sound;
- (void)playSoundWithName:(NSString*)name andExtension:(NSString*)extension;
- (void)playSoundWithFileURL:(NSURL*)fileURL;

- (NSString *)nameForOutputPort;
- (NSString *)subtitleForOutputPort;
- (NSString *)subtitleForOutputPort:(OutputPort)port;

@end
