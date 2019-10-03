//
//  SupportTopicAPI.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 5/26/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "LIOptionDataModel.h"
#import "RABaseAPI.h"
#import "RASupportTopic.h"

typedef void(^SupportTopicBlock)(NSArray<RASupportTopic*>* _Nullable supportTopics,NSError * _Nullable error);
typedef void(^SupportTopicPostMessageBlock)(NSError* _Nullable error);
typedef void(^LostAndFoundBlock)(NSString * _Nullable message, NSError * _Nullable error);

@interface SupportTopicAPI : RABaseAPI

+ (void)getSupportTopicListWithCompletion:(SupportTopicBlock _Nonnull)handler;
+ (void)getTopicsWithParentId:(NSNumber *_Nonnull)parentTopicId withCompletion:(SupportTopicBlock _Nonnull)handler;
+ (void)getFormForTopic:(RASupportTopic *_Nonnull)topic withCompletion:(void(^_Nonnull)(LIOptionDataModel *_Nullable, NSError *_Nullable))completion;
+ (void)postSupportMessage:(NSString *_Nonnull)comment supportTopic:(RASupportTopic*_Nonnull)supportTopic rideId:(NSNumber*_Nonnull)rideId withCompletion:(SupportTopicPostMessageBlock _Nonnull)handler;
+ (void)postSupportMessage:(NSString *_Nonnull)message rideID:(NSString *_Nonnull)rideID withCompletion:(void (^_Nonnull)(id _Nullable response, NSError * _Nullable error))completion;

#pragma mark - Rider Lost Items
+ (void)postLostAndFoundLostParameters:(NSDictionary *_Nonnull)params
                        withCompletion:(LostAndFoundBlock _Nonnull )completion;
+ (void)postLostAndFoundContactParameters:(NSDictionary *_Nonnull)params
                           withCompletion:(LostAndFoundBlock _Nonnull )completion;

#pragma mark Driver Lost Items
+ (void)postLostAndFoundFoundParameters:(NSDictionary *_Nonnull)params
                              andImages:(NSDictionary<NSString *, NSData *> *_Nullable)images
                         withCompletion:(LostAndFoundBlock _Nonnull )completion;
@end
