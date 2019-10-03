//
//  RACallKitManager.h
//  RideDriver
//
//  Created by Kitos on 27/10/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RARequestRideCall.h"
#import "RideDriverEnums.h"

typedef void(^RACallKitRequestRideCallCompletionBlock)(RARequestRideCall *call, NSError* error);
typedef void(^RACallKitCompletionBlock)(NSError* error);

@interface RACallKitManager : NSObject

+ (BOOL)isCallKitAvailable;
+ (NSString*)nameFromOption:(CallSetting)callSetting;

+ (RACallKitManager*)sharedManager;

- (void)reportIncomingCallForRideWithId:(NSString *)rideId name:(NSString *)name title:(NSString *)title completion:(RACallKitRequestRideCallCompletionBlock)completion;
- (void)endCallWithCompletion:(RACallKitCompletionBlock)completion;
- (void)endCallForRideWithId:(NSString *)rideId completion:(RACallKitCompletionBlock)completion;

@end
