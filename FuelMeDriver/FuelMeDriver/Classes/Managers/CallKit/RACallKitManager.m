//
//  RACallKitManager.m
//  RideDriver
//
//  Created by Kitos on 27/10/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "RACallKitManager.h"

#import <CallKit/CallKit.h>

#import "ErrorReporter.h"

@interface RACallKitManager ()

@property (nonatomic, copy) RACallKitRequestRideCallCompletionBlock incomingCallCompletionBlock;

@property (nonatomic, strong) CXProvider *provider;
@property (nonatomic, strong) CXCallController *callController;
@property (nonatomic, strong) RARequestRideCall *call;
@property (nonatomic) BOOL avoidIncomingCompletion;

@end

@interface RACallKitManager (ProviderDelegate) <CXProviderDelegate>

@end

@interface RACallKitManager (TimeUpdate)

- (void)updateTime:(NSNumber*)time;

@end

@interface NSString (ProviderConfiguration)

- (CXProviderConfiguration *)providerConfiguration;

@end

@interface RACallKitManager (Private)

- (CXProvider *)providerWithName:(NSString *)name;

- (void)reportIncomingCall:(RARequestRideCall*)call withCompletion:(RACallKitCompletionBlock)handler;
- (void)requestTransaction:(CXTransaction*)transaction withCompletion:(RACallKitCompletionBlock)handler;

- (void)endCallWithUUID:(NSUUID*)uuid completion:(RACallKitCompletionBlock)handler;
- (void)purgeCall;

@end

static RACallKitManager *_sharedManager;

@implementation RACallKitManager

+ (BOOL)isCallKitAvailable {
    return [[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0;
}

+ (NSString*)nameFromOption:(CallSetting)callSetting {
    switch (callSetting) {
        case AcceptRequest:
            return @"Accept Request";
        case OpenApp:
            return @"Open App";
            break;
        default:
            return @"";
            break;
    }
}

+ (RACallKitManager *)sharedManager {
    if (!_sharedManager) {
        _sharedManager = [RACallKitManager new];
    }
    return _sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.callController = [[CXCallController alloc] initWithQueue:dispatch_get_main_queue()];
    }
    return self;
}

- (void)reportIncomingCallForRideWithId:(NSString *)rideId name:(NSString *)name title:(NSString *)title completion:(RACallKitRequestRideCallCompletionBlock)completion {
    [self reportIncomingCallForRideWithId:rideId name:name title:title timeout:0 completion:completion];
}

- (void)reportIncomingCallForRideWithId:(NSString *)rideId name:(NSString *)name title:(NSString *)title timeout:(NSTimeInterval)timeout completion:(RACallKitRequestRideCallCompletionBlock)completion {
    if (!self.call) {
        self.avoidIncomingCompletion = NO;
        
        __weak typeof(self) weakSelf = self;
        
        self.call = [[RARequestRideCall alloc] initWithName:name title:title rideId:rideId];
        self.incomingCallCompletionBlock = completion;
        
        [self reportIncomingCall:self.call withCompletion:^(NSError *error) {
            if (error) {
                [ErrorReporter recordErrorDomainName:CKStartCall withUserInfo:@{NSLocalizedDescriptionKey: error.localizedDescription, @"Call":@{@"name":weakSelf.call.name,@"title":weakSelf.call.title, @"answered":weakSelf.call.answered?@"Yes":@"No"}}];
                
                if (weakSelf.incomingCallCompletionBlock) {
                    weakSelf.incomingCallCompletionBlock(weakSelf.call,error);
                }
                
                [weakSelf purgeCall];
            }
            else{
                if (timeout > 0) {
                    [weakSelf updateTime:[NSNumber numberWithDouble:timeout]];
                }
            }
        }];
    }
}

- (void)endCallWithCompletion:(RACallKitCompletionBlock)handler {
    if (self.call) {
        self.avoidIncomingCompletion = YES;
        [self endCallWithUUID:self.call.uuid completion:handler];
    }
}

- (void)endCallForRideWithId:(NSString *)rideId completion:(RACallKitCompletionBlock)completion {
    if (self.call && [self.call.rideId isEqualToString:rideId]) {
        [self endCallWithCompletion:completion];
    }
}

@end

#pragma mark - Provider Delegate

@implementation RACallKitManager (ProviderDelegate)

- (void)providerDidReset:(CXProvider *)provider {
    
}

- (void)provider:(CXProvider *)provider performEndCallAction:(CXEndCallAction *)action {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateTime:) object:nil];

    self.call.declined = YES;
    if (!self.avoidIncomingCompletion && self.incomingCallCompletionBlock) {
        self.incomingCallCompletionBlock(self.call,nil);
    }

    [self purgeCall];
    [action fulfill];
}

- (void)provider:(CXProvider *)provider performAnswerCallAction:(CXAnswerCallAction *)action {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateTime:) object:nil];

    self.call.answered = YES;
    if (self.incomingCallCompletionBlock) {
        self.incomingCallCompletionBlock(self.call,nil);
    }

    [action fulfill];
}

@end

#pragma mark - Update Time

@implementation RACallKitManager (TimeUpdate)

- (void)updateTime:(NSNumber *)time {
    if ([self.call isInProgress]) {
        CXCallUpdate *update = [[CXCallUpdate alloc] init];
        update.localizedCallerName = [NSString stringWithFormat:@"%ld %@",(long)time.integerValue, self.call.name];
        [self.provider reportCallWithUUID:self.call.uuid updated:update];
        NSInteger t = time.integerValue;
        t--;
        if (t>=0) {
            NSNumber *timeLeft = [NSNumber numberWithInteger:t];
            if ([self respondsToSelector:@selector(updateTime:)]) {
                [self performSelector:@selector(updateTime:) withObject:timeLeft afterDelay:1];
            }
        }
        else{
            if (self.call) {
                [self.provider reportCallWithUUID:self.call.uuid endedAtDate:nil reason:CXCallEndedReasonUnanswered];
                
                if (self.incomingCallCompletionBlock) {
                    self.incomingCallCompletionBlock(self.call,nil);
                }
                
                [self purgeCall];
            }   
        }
    }
}

@end

#pragma Provider from NSString

@implementation NSString (Provider)

- (CXProviderConfiguration *)providerConfiguration {
    CXProviderConfiguration *providerConfiguration = [[CXProviderConfiguration alloc] initWithLocalizedName:self];
    providerConfiguration.maximumCallGroups = 1;
    providerConfiguration.maximumCallsPerCallGroup = 1;
    providerConfiguration.supportedHandleTypes = [NSSet setWithObject: @(CXHandleTypePhoneNumber)];
    providerConfiguration.iconTemplateImageData = UIImagePNGRepresentation([UIImage imageNamed:@"callkit_icon2"]);
    return providerConfiguration;
}

@end

#pragma mark - Private

@implementation RACallKitManager (Private)

- (CXProvider *)providerWithName:(NSString *)name {
    CXProvider *provider = [[CXProvider alloc] initWithConfiguration:[name providerConfiguration]];
    [provider setDelegate:self queue:dispatch_get_main_queue()];

    return provider;
}

- (void)reportIncomingCall:(RARequestRideCall *)call withCompletion:(RACallKitCompletionBlock)handler {
    CXCallUpdate *callUpdate = [CXCallUpdate new];
    callUpdate.localizedCallerName = call.name;
    callUpdate.supportsHolding = NO;
    callUpdate.supportsGrouping = NO;
    
    [self.provider invalidate];
    self.provider = [self providerWithName:call.title];
    
    [self.provider reportNewIncomingCallWithUUID:call.uuid update:callUpdate completion:^(NSError * _Nullable error) {
        if (handler) {
            handler(error);
        }
    }];
}

- (void)requestTransaction:(CXTransaction *)transaction withCompletion:(RACallKitCompletionBlock)handler {
    [self.callController requestTransaction:transaction completion:^(NSError * _Nullable error) {
        if (handler) {
            handler(error);
        }
    }];
}

- (void)endCallWithUUID:(NSUUID *)uuid completion:(RACallKitCompletionBlock)handler {
    __weak typeof(self) weakSelf = self;

    CXEndCallAction *endAction = [[CXEndCallAction alloc]initWithCallUUID:uuid];
    CXTransaction *transaction = [[CXTransaction alloc]initWithAction:endAction];

    [self requestTransaction:transaction withCompletion:^(NSError *error) {
        
        if (handler) {
            handler(error);
        }

        if (error) {
            
            //FIX RA-5589 - check call before report error (avoid crash on "Call" dictionary with null values)
            if (weakSelf.call) {
                
                DBLog(@"CALL: %@", weakSelf.call);
                DBLog(@"NAME: %@", weakSelf.call.name);
                DBLog(@"TITLE: %@", weakSelf.call.title);
                DBLog(@"ANSWER: %d", weakSelf.call.answered);
                
                NSString* name = IS_EMPTY(weakSelf.call.name) ? @"" : weakSelf.call.name;
                NSString* title = IS_EMPTY(weakSelf.call.title) ? @"" : weakSelf.call.title;
                NSString* answered = weakSelf.call.answered ? @"YES" : @"NO";
                
                [ErrorReporter recordErrorDomainName:CKEndCall withUserInfo:@{NSLocalizedDescriptionKey: error.localizedDescription, @"Call":@{@"name":name,@"title":title, @"answered":answered}}];
                
            } else {
                //FIX RA-5589 - report error without user info
                [ErrorReporter recordError:error withDomainName:CKEndCall];
            }
            
            
            
            [weakSelf purgeCall];
            [endAction fail];
            DBLog(@"end call error: %@",error);
        }
    }];
}

- (void)purgeCall {
    self.incomingCallCompletionBlock = nil;
    self.call = nil;
}

@end
