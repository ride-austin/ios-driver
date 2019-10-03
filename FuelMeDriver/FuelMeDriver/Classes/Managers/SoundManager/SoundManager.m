//
//  SoundManager.m
//  RideDriver
//
//  Created by Carlos Alcala on 12/13/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "SoundManager.h"

#import "ErrorReporter.h"

@interface SoundManager() <AVAudioPlayerDelegate>
@property (nonatomic, assign) float volume;
@end

@implementation SoundManager

- (instancetype)init {
    if (self = [super init]) {
        //setup player by default
        self.playerType = AVPlayerType;
        self.port = Default;
        self.volume = 1.0;
    }
    return self;
}

+ (SoundManager*)sharedManager {
    static SoundManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}

- (void)configureAudioSession {
    
    NSError * error;
    
    /**
     Taken from Waze
     https://wiki.waze.com/wiki/index.php/Source_code roadmap_sound.m
     */
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback
                                     withOptions:AVAudioSessionCategoryOptionDuckOthers | AVAudioSessionCategoryOptionMixWithOthers
                                           error:&error];
    if (error) {
        DBLog(@"ERROR: %@", error.localizedDescription);
    }
    
    [[AVAudioSession sharedInstance] setPreferredIOBufferDuration:0.005 error:&error];
    if (error) {
        DBLog(@"ERROR: %@", error.localizedDescription);
    }
}

- (void)setPort:(OutputPort)port {
    _port = port;
    [self updateAudioPort:self.port];
}

- (void)updateAudioPort:(OutputPort)port {
    
    NSError * error;
    switch (port) {
        case Default:
            [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&error];
            break;
        case Speakers:
            [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
            break;
    }
    
    if(error) {
        DBLog(@"ERROR: %@", error.localizedDescription);
    }
}

- (void)setPlayerType:(PlayerType)playerType {
    _playerType = playerType;

    //configure on AVPlayerType
    if (playerType == AVPlayerType) {
        [self configureAudioSession];
    }
}

- (void)setVolume:(float)volume {
    if (volume > 1) {
        _volume = 1.0;
    } else {
        _volume = volume;
    }
}

#pragma mark - Play Audio by SystemSound

- (void)playSound:(SystemSound)sound {
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (self.playerType) {
            case AVPlayerType: {
                NSString *path = [NSString stringWithFormat:@"/System/Library/Audio/UISounds/%@", [self filenameForSystemSound:sound]];
                NSURL *fileURL = [NSURL URLWithString:path];
                [self playSoundWithFileURL:fileURL];
                break;
            }
            case SystemPlayerType: {
                AudioServicesPlaySystemSound(sound);
                break;
            }
        }
    });
}

- (void)playSoundWithName:(NSString*)name andExtension:(NSString*)extension {
    NSString *path  = [[NSBundle mainBundle] pathForResource:name ofType:extension];
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    
    //Try to play sound with fileURL
    [self playSoundWithFileURL:fileURL];
}

- (void)playSoundWithFileURL:(NSURL *)fileURL {
    
    NSError * error;
    
    if (!fileURL) {
        //Sound File Not Found
        [ErrorReporter recordErrorDomainName:SoundFileNotFound withUserInfo:@{@"fileURL":fileURL}];
        return;
    }
    
    DBLog(@"FILE URL: %@", fileURL);
    
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&error];
    self.player.delegate = self;
    if (error) {
        //AVPlayer failed to initialize
        DBLog(@"ERROR: %@", error.localizedDescription);
        [ErrorReporter recordError:error withDomainName:SoundPlayerFailed];
        return;
    }
    
    //setup player options
    self.player.volume = self.volume;
    self.player.numberOfLoops = JustOnce; // -1 Infinite | 0 Just Once
    [self.player prepareToPlay];
    
    //Play with AVPlayer
    [self.player play];
}

#pragma mark - String Helpers

- (NSString *)nameForOutputPort {
    switch (self.port) {
        case Default:       return @"Default";
        case Speakers:      return @"Speakers";
    }
}

- (NSString *)subtitleForOutputPort {
    return [self subtitleForOutputPort:self.port];
}

- (NSString *)subtitleForOutputPort:(OutputPort)port {
    switch (port) {
        case Default:       return @"Current Output";
        case Speakers:      return @"iPhone Speakers";
    }
}

- (NSString *)stringForSystemSound:(SystemSound)sound {
    switch (sound) {
        case MailReceived:                return @"MailReceived";
        case MailSent:                    return @"MailSent";
        case VoicemailReceived:           return @"VoicemailReceived";
        case SMSReceived:                 return @"SMSReceived";
        case SMSSent1:                    return @"SMSSent1";
        case CalendarAlert:               return @"CalendarAlert";
        case LowPower:                    return @"LowPower";
        case SMSReceived_Alert1:          return @"SMSReceived_Alert1";
        case SMSReceived_Alert2:          return @"SMSReceived_Alert2";
        case SMSReceived_Alert3:          return @"SMSReceived_Alert3";
        case SMSReceived_Alert4:          return @"SMSReceived_Alert4";
        case SMSReceived_Vibrate1:        return @"SMSReceived_Vibrate1";
        case SMSReceived_Alert5:          return @"SMSReceived_Alert5";
        case SMSReceived_Alert6:          return @"SMSReceived_Alert6";
        case SMSReceived_Alert7:          return @"SMSReceived_Alert7";
        case Voicemail:                   return @"Voicemail";
        case SMSSent2:                    return @"SMSSent2";
        case SMSReceived_Alert8:          return @"SMSReceived_Alert8";
        case SMSReceived_Alert9:          return @"SMSReceived_Alert9";
        case SMSReceived_Alert10:         return @"SMSReceived_Alert10";
        case SMSReceived_Alert11:         return @"SMSReceived_Alert11";
        case SMSReceived_Alert12:         return @"SMSReceived_Alert12";
        case SMSReceived_Alert13:         return @"SMSReceived_Alert13";
        case SMSReceived_Alert14:         return @"SMSReceived_Alert14";
        case SMSReceived_Alert15:         return @"SMSReceived_Alert15";
        case SMSReceived_Alert16:         return @"SMSReceived_Alert16";
        case SMSReceived_Alert17:         return @"SMSReceived_Alert17";
        case SMSReceived_Alert18:         return @"SMSReceived_Alert18";
        case SMSReceived_Alert19:         return @"SMSReceived_Alert19";
        case SMSReceived_Alert21:         return @"SMSReceived_Alert21";
        case SMSReceived_Alert22:         return @"SMSReceived_Alert22";
        case SMSReceived_Alert23:         return @"SMSReceived_Alert23";
        case SMSReceived_Alert24:         return @"SMSReceived_Alert24";
        case SMSReceived_Alert25:         return @"SMSReceived_Alert25";
        case USSDAlert:                   return @"USSDAlert";
        case SIMToolkitTone1:             return @"SIMToolkitTone1";
        case SIMToolkitTone2:             return @"SIMToolkitTone2";
        case SIMToolkitTone3:             return @"SIMToolkitTone3";
        case SIMToolkitTone4:             return @"SIMToolkitTone4";
        case SIMToolkitTone5:             return @"SIMToolkitTone5";
        case PINKeyPressed:               return @"PINKeyPressed";
        case AudioToneBusy:               return @"AudioToneBusy";
        case AudioToneCongestion:         return @"AudioToneCongestion";
        case AudioTonePathAcknowledge:    return @"AudioTonePathAcknowledge";
        case AudioToneError:              return @"AudioToneError";
        case AudioToneCallWaiting:        return @"AudioToneCallWaiting";
        case AudioToneKey:                return @"AudioToneKey";
        case ScreenLocked:                return @"ScreenLocked";
        case ScreenUnlocked:              return @"ScreenUnlocked";
        case FailedUnlock:                return @"FailedUnlock";
        case KeyPressed1:                 return @"KeyPressed1";
        case KeyPressed2:                 return @"KeyPressed2";
        case KeyPressed3:                 return @"KeyPressed3";
        case ConnectedToPower:            return @"ConnectedToPower";
        case RingerSwitchIndication:      return @"RingerSwitchIndication";
        case CameraShutter:               return @"CameraShutter";
        case ShakeToShuffle:              return @"ShakeToShuffle";
        case JBL_Begin:                   return @"JBL_Begin";
        case JBL_Confirm:                 return @"JBL_Confirm";
        case JBL_Cancel:                  return @"JBL_Cancel";
        case BeginRecording:              return @"BeginRecording";
        case EndRecording:                return @"EndRecording";
        case JBL_Ambiguous:               return @"JBL_Ambiguous";
        case JBL_NoMatch:                 return @"JBL_NoMatch";
        case BeginVideoRecording:         return @"BeginVideoRecording";
        case EndVideoRecording:           return @"EndVideoRecording";
        case VCInvitationAccepted:        return @"VCInvitationAccepted";
        case VCRinging:                   return @"VCRinging";
        case VCEnded:                     return @"VCEnded";
        case VCCallWaiting:               return @"VCCallWaiting";
        case VCCallUpgrade:               return @"VCCallUpgrade";
        case TouchTone0:                  return @"TouchTone0";
        case TouchTone1:                  return @"TouchTone1";
        case TouchTone2:                  return @"TouchTone2";
        case TouchTone3:                  return @"TouchTone3";
        case TouchTone4:                  return @"TouchTone4";
        case TouchTone5:                  return @"TouchTone5";
        case TouchTone6:                  return @"TouchTone6";
        case TouchTone7:                  return @"TouchTone7";
        case TouchTone8:                  return @"TouchTone8";
        case TouchTone9:                  return @"TouchTone9";
        case TouchTone10:                 return @"TouchTone10";
        case TouchTone11:                 return @"TouchTone11";
        case Headset_StartCall:           return @"Headset_StartCall";
        case Headset_Redial:              return @"Headset_Redial";
        case Headset_AnswerCall:          return @"Headset_AnswerCall";
        case Headset_EndCall:             return @"Headset_EndCall";
        case Headset_CallWaitingAction:   return @"Headset_CallWaitingAction";
        case Headset_TransitionEnd:       return @"Headset_TransitionEnd";
        case SystemSoundPreview0:         return @"SystemSoundPreview0";
        case SystemSoundPreview1:         return @"SystemSoundPreview1";
        case SystemSoundPreview2:         return @"SystemSoundPreview2";
        case SystemSoundPreview3:         return @"SystemSoundPreview3";
        case SystemSoundPreview4:         return @"SystemSoundPreview4";
        case SystemSoundPreview5:         return @"SystemSoundPreview5";
        case KeyPressClickPreview:        return @"KeyPressClickPreview";
        case SMSReceived_Selection0:      return @"SMSReceived_Selection0";
        case SMSReceived_Selection1:      return @"SMSReceived_Selection1";
        case SMSReceived_Selection2:      return @"SMSReceived_Selection2";
        case SMSReceived_Selection3:      return @"SMSReceived_Selection3";
        case SMSReceived_Vibrate2:        return @"SMSReceived_Vibrate2";
        case SMSReceived_Selection4:      return @"SMSReceived_Selection4";
        case SMSReceived_Selection5:      return @"SMSReceived_Selection5";
        case SMSReceived_Selection6:      return @"SMSReceived_Selection6";
        case SystemSoundPreview6:         return @"SystemSoundPreview6";
        case SMSReceived_Selection7:      return @"SMSReceived_Selection7";
        case SMSReceived_Selection8:      return @"SMSReceived_Selection8";
        case SMSReceived_Selection9:      return @"SMSReceived_Selection9";
        case SMSReceived_Selection10:     return @"SMSReceived_Selection10";
        case SMSReceived_Selection11:     return @"SMSReceived_Selection11";
        case SMSReceived_Selection12:     return @"SMSReceived_Selection12";
        case SMSReceived_Selection13:     return @"SMSReceived_Selection13";
        case SMSReceived_Selection14:     return @"SMSReceived_Selection14";
        case SMSReceived_Selection15:     return @"SMSReceived_Selection15";
        case SMSReceived_Selection16:     return @"SMSReceived_Selection16";
        case SMSReceived_Selection17:     return @"SMSReceived_Selection17";
        case SMSReceived_Selection18:     return @"SMSReceived_Selection18";
        case SMSReceived_Selection19:     return @"SMSReceived_Selection19";
        case SMSReceived_Selection20:     return @"SMSReceived_Selection20";
        case SMSReceived_Selection21:     return @"SMSReceived_Selection21";
        case SMSReceived_Selection22:     return @"SMSReceived_Selection22";
        case SMSReceived_Selection23:     return @"SMSReceived_Selection23";
        case RingerVibeChanged:           return @"RingerVibeChanged";
        case SilentVibeChanged:           return @"SilentVibeChanged";
        case Vibrate:                     return @"Vibrate";
    }
    
}

- (NSString *)filenameForSystemSound:(SystemSound)sound {
    switch (sound) {
        case MailReceived:                return @"new-mail.caf";
        case MailSent:                    return @"mail-sent.caf";
        case VoicemailReceived:           return @"Voicemail.caf";
        case SMSReceived:                 return @"ReceivedMessage.caf";
        case SMSSent1:                    return @"SentMessage.caf";
        case CalendarAlert:               return @"alarm.caf";
        case LowPower:                    return @"low_power.caf";
        case SMSReceived_Alert1:          return @"sms-received1.caf";
        case SMSReceived_Alert2:          return @"sms-received2.caf";
        case SMSReceived_Alert3:          return @"sms-received3.caf";
        case SMSReceived_Alert4:          return @"sms-received4.caf";
        case SMSReceived_Vibrate1:        return @"";
        case SMSReceived_Alert5:          return @"sms-received1.caf";
        case SMSReceived_Alert6:          return @"sms-received5.caf";
        case SMSReceived_Alert7:          return @"sms-received6.caf";
        case Voicemail:                   return @"Voicemail.caf";
        case SMSSent2:                    return @"tweet_sent.caf";
        case SMSReceived_Alert8:          return @"New/Anticipate.caf";
        case SMSReceived_Alert9:          return @"New/Bloom.caf";
        case SMSReceived_Alert10:         return @"New/Calypso.caf";
        case SMSReceived_Alert11:         return @"New/Choo_Choo.caf";
        case SMSReceived_Alert12:         return @"New/Descent.caf";
        case SMSReceived_Alert13:         return @"New/Fanfare.caf";
        case SMSReceived_Alert14:         return @"New/Ladder.caf";
        case SMSReceived_Alert15:         return @"New/Minuet.caf";
        case SMSReceived_Alert16:         return @"New/News_Flash.caf";
        case SMSReceived_Alert17:         return @"New/Noir.caf";
        case SMSReceived_Alert18:         return @"New/Sherwood_Forest.caf";
        case SMSReceived_Alert19:         return @"New/Spell.caf";
        case SMSReceived_Alert21:         return @"New/Suspense.caf";
        case SMSReceived_Alert22:         return @"New/Telegraph.caf";
        case SMSReceived_Alert23:         return @"New/Tiptoes.caf";
        case SMSReceived_Alert24:         return @"New/Typewriters.caf";
        case SMSReceived_Alert25:         return @"New/Update.caf";
        case USSDAlert:                   return @"ussd.caf";
        case SIMToolkitTone1:             return @"SIMToolkitCallDropped.caf";
        case SIMToolkitTone2:             return @"SIMToolkitGeneralBeep.caf";
        case SIMToolkitTone3:             return @"SIMToolkitNegativeACK.caf";
        case SIMToolkitTone4:             return @"SIMToolkitPositiveACK.caf";
        case SIMToolkitTone5:             return @"SIMToolkitSMS.caf";
        case PINKeyPressed:               return @"Tink.caf";
        case AudioToneBusy:               return @"ct-busy.caf";
        case AudioToneCongestion:         return @"ct-congestion.caf";
        case AudioTonePathAcknowledge:    return @"ct-path-ack.caf";
        case AudioToneError:              return @"ct-error.caf";
        case AudioToneCallWaiting:        return @"ct-call-waiting.caf";
        case AudioToneKey:                return @"ct-keytone2.caf";
        case ScreenLocked:                return @"lock.caf";
        case ScreenUnlocked:              return @"unlock.caf";
        case FailedUnlock:                return @"";
        case KeyPressed1:                 return @"Tink.caf";
        case KeyPressed2:                 return @"Tock.caf";
        case KeyPressed3:                 return @"Tock.caf";
        case ConnectedToPower:            return @"beep-beep.caf";
        case RingerSwitchIndication:      return @"RingerChanged.caf";
        case CameraShutter:               return @"photoShutter.caf";
        case ShakeToShuffle:              return @"shake.caf";
        case JBL_Begin:                   return @"jbl_begin.caf";
        case JBL_Confirm:                 return @"jbl_confirm.caf";
        case JBL_Cancel:                  return @"jbl_cancel.caf";
        case BeginRecording:              return @"begin_record.caf";
        case EndRecording:                return @"end_record.caf";
        case JBL_Ambiguous:               return @"jbl_ambiguous.caf";
        case JBL_NoMatch:                 return @"jbl_no_match.caf";
        case BeginVideoRecording:         return @"begin_video_record.caf";
        case EndVideoRecording:           return @"end_video_record.caf";
        case VCInvitationAccepted:        return @"vc~invitation-accepted.caf";
        case VCRinging:                   return @"vc~ringing.caf";
        case VCEnded:                     return @"vc~ended.caf";
        case VCCallWaiting:               return @"ct-call-waiting.caf";
        case VCCallUpgrade:               return @"vc~ringing.caf";
        case TouchTone0:                  return @"dtmf-0.caf";
        case TouchTone1:                  return @"dtmf-1.caf";
        case TouchTone2:                  return @"dtmf-2.caf";
        case TouchTone3:                  return @"dtmf-3.caf";
        case TouchTone4:                  return @"dtmf-4.caf";
        case TouchTone5:                  return @"dtmf-5.caf";
        case TouchTone6:                  return @"dtmf-6.caf";
        case TouchTone7:                  return @"dtmf-7.caf";
        case TouchTone8:                  return @"dtmf-8.caf";
        case TouchTone9:                  return @"dtmf-9.caf";
        case TouchTone10:                 return @"dtmf-star.caf";
        case TouchTone11:                 return @"dtmf-pound.caf";
        case Headset_StartCall:           return @"long_low_short_high.caf";
        case Headset_Redial:              return @"short_double_high.caf";
        case Headset_AnswerCall:          return @"short_low_high.caf";
        case Headset_EndCall:             return @"short_double_low.caf";
        case Headset_CallWaitingAction:   return @"short_double_low.caf";
        case Headset_TransitionEnd:       return @"middle_9_short_double_low.caf";
        case SystemSoundPreview0:         return @"Voicemail.caf";
        case SystemSoundPreview1:         return @"ReceivedMessage.caf";
        case SystemSoundPreview2:         return @"new-mail.caf";
        case SystemSoundPreview3:         return @"mail-sent.caf";
        case SystemSoundPreview4:         return @"alarm.caf";
        case SystemSoundPreview5:         return @"lock.caf";
        case KeyPressClickPreview:        return @"Tock.caf";
        case SMSReceived_Selection0:      return @"sms-received1.caf";
        case SMSReceived_Selection1:      return @"sms-received2.caf";
        case SMSReceived_Selection2:      return @"sms-received3.caf";
        case SMSReceived_Selection3:      return @"sms-received4.caf";
        case SMSReceived_Vibrate2:        return @"";
        case SMSReceived_Selection4:      return @"sms-received1.caf";
        case SMSReceived_Selection5:      return @"sms-received5.caf";
        case SMSReceived_Selection6:      return @"sms-received6.caf";
        case SystemSoundPreview6:         return @"Voicemail.caf";
        case SMSReceived_Selection7:      return @"New/Anticipate.caf";
        case SMSReceived_Selection8:      return @"New/Bloom.caf";
        case SMSReceived_Selection9:      return @"New/Calypso.caf";
        case SMSReceived_Selection10:     return @"New/Choo_Choo.caf";
        case SMSReceived_Selection11:     return @"New/Descent.caf";
        case SMSReceived_Selection12:     return @"New/Fanfare.caf";
        case SMSReceived_Selection13:     return @"New/Ladder.caf";
        case SMSReceived_Selection14:     return @"New/Minuet.caf";
        case SMSReceived_Selection15:     return @"New/News_Flash.caf";
        case SMSReceived_Selection16:     return @"New/Noir.caf";
        case SMSReceived_Selection17:     return @"New/Sherwood_Forest.caf";
        case SMSReceived_Selection18:     return @"New/Spell.caf";
        case SMSReceived_Selection19:     return @"New/Suspense.caf";
        case SMSReceived_Selection20:     return @"New/Telegraph.caf";
        case SMSReceived_Selection21:     return @"New/Tiptoes.caf";
        case SMSReceived_Selection22:     return @"New/Typewriters.caf";
        case SMSReceived_Selection23:     return @"New/Update.caf";
        case RingerVibeChanged:           return @"";
        case SilentVibeChanged:           return @"";
        case Vibrate:                     return @"";
    }
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
}

@end
