//
//  EventStubModel.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 6/4/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RAEventDataModel.h"

@interface EventStubModel : NSObject
@property (nonatomic, readonly) RAEventDataModel * _Nullable model;
/**
 Initializer

 @param secondsFromLaunch time from launch date
 @param launchDate time reference data to determine responseDate
 @param modelID modelId that will be attached to json object
 @param jsonObject array or data that represents a JSON object
 */
-(instancetype _Nonnull)initWithSeconds:(NSTimeInterval)secondsFromLaunch launchDate:(NSDate *_Nonnull)launchDate model:(RAEventDataModel *_Nullable)model;

/**
 events endpoint expects an array
 
 @return an array with model if existing
 */
-(NSArray *_Nonnull)jsonArray;
-(BOOL)isInPresentOrPast;
@end

@interface EventStubModel (RequestModelIDComparison)

/**
 *  @return YES, if event id is larger than lastReceivedEvent or lastReceivedEvent is nil
 */
-(BOOL)isNotYetReceivedByRequest:(NSURLRequest *_Nonnull)request;
@end

@interface EventStubModel (Duplication)
+(instancetype _Nonnull )eventStubFromStub:(EventStubModel *_Nonnull)stub afterSeconds:(NSTimeInterval)seconds;
@end
