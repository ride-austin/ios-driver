//
//  RARideAPI.h
//  RideDriver
//
//  Created by Roberto Abreu on 6/7/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RABaseAPI.h"
#import "RARideDataModel.h"
NS_ASSUME_NONNULL_BEGIN
typedef void(^RideCompletionBlock)(RARideDataModel * _Nullable ride, NSError * _Nullable error);
typedef void(^RideUpgradeCompletionBlock)(NSString * _Nullable message, NSError *_Nullable error);
typedef void(^StatusCompletionBlock)(NSInteger statusCode, NSError *_Nullable error);
typedef void(^RideMapCompletionBlock)(NSURL * _Nullable mapURL, NSError *_Nullable error);
typedef void(^IsRideActiveBlock)(BOOL isRideActive, NSError *_Nullableerror);

@interface RARideAPI : RABaseAPI

+ (void)getCurrentRideWithCompletion:(RideCompletionBlock)completion;
+ (void)postEvents:(NSDictionary *)events withCompletion:(void(^)(NSError *))completion;
+ (void)ackReceivedRideWithId:(NSNumber*)rideId completion:(StatusCompletionBlock)completion;
+ (void)acceptRideWithId:(NSNumber *)rideId andCompletion:(void(^)(NSError *))completion;
+ (void)startRideWithId:(NSString*)rideId latitude:(double)lat longitude:(double)lng andCompletion:(StatusCompletionBlock)completion;
+ (void)reachedRideWithId:(NSString*)rideId andCompletion:(StatusCompletionBlock)completion;
+ (void)endRideWithId:(NSString*)rideId latitude:(double)lat longitude:(double)lng andCompletion:(RideCompletionBlock)completion;
+ (void)getRideWithId:(NSString*)rideId andCompletion:(RideCompletionBlock)completion;
+ (void)isRideActiveWithId:(NSString *)rideId andCompletion:(IsRideActiveBlock)completion;
+ (void)getMapURLForRideWithId:(NSString*)rideId andCompletion:(RideMapCompletionBlock)completion;
+ (void)declineRideWithId:(NSNumber *)rideId andCompletion:(APIErrorResponseBlock _Nullable)completion;

+ (void)cancelRide:(NSString*)rideId withReason:(NSString *_Nullable)reasonCode andComment:(NSString *_Nullable)comment andCompletion:(APIErrorResponseBlock)completion;
+ (void)addRate:(float)rating toRideWithId:(NSString*)rideId andCompletionBlock:(APIErrorResponseBlock)completion;
+ (void)requestUpgradeWithCategoryTarget:(NSString*)categoryTarget andCompletion:(RideUpgradeCompletionBlock)completion;
+ (void)declineUpgradeWithCompletion:(RideUpgradeCompletionBlock)completion;
NS_ASSUME_NONNULL_END
@end

#import "CFReasonDataModel.h"
@interface RARideAPI (CancellationFeedback)

+ (void)getReasonsWithCompletion:(void(^_Nonnull)(NSArray<CFReasonDataModel *> * _Nullable reasons, NSError * _Nullable error))completion;

@end
