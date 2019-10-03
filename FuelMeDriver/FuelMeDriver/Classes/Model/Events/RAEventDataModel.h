//
//  RAEventDataModel.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 6/4/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RAEventsProtocol.h"
#import "RARideDataModel.h"
#import "RideDriverEnums.h"

#import <Mantle/Mantle.h>

@interface RAEventDataModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy, readonly) RARideDataModel * _Nullable ride;
@property (nonatomic, copy, readonly) RARideDataModel * _Nullable nextRide;
@property (nonatomic, copy, readonly) NSNumber * _Nonnull modelID;
@property (nonatomic, copy, readonly) NSString * _Nullable message;
@property (nonatomic, copy, readonly) NSString * _Nullable title;
@property (nonatomic, copy, readonly) NSString * _Nonnull eventType;

- (DriverEventType)type;

@end

@interface RAEventDataModel (RAHandShakeEventProtocol) <RAHandShakeEventProtocol>
@end

@interface RAEventDataModel (RARideRequestProtocol) <RARideRequestProtocol>
@end

@interface RAEventDataModel (RARiderLocationUpdateProtocol)<RARiderLocationUpdateProtocol>
@end

@interface RAEventDataModel (RAInactiveEventProtocol) <RAInactiveEventProtocol>
@end

@interface RAEventDataModel (RAQueueEventProtocol) <RAQueueEventProtocol>
@end

@interface RAEventDataModel (RAQueueEventPenaltyProtocol) <RAQueueEventPenaltyProtocol>
@end

@interface RAEventDataModel (RACarCategoryChangedEventProtocol) <RACarCategoryChangedEventProtocol>
@end

@interface RAEventDataModel (RASurgeAreaEventProtocol) <RASurgeAreaEventProtocol>
@end

@interface RAEventDataModel (RARideUpgradeEventProtocol) <RARideUpgradeEventProtocol>
@end

#pragma mark - EventStubGenerator (Test)

@interface RAEventDataModel (EventStubGenerator)
+ (instancetype _Nonnull)eventRequestedWithRide:(RARideDataModel *_Nonnull)ride modelId:(NSNumber *_Nonnull)modelId;
+ (instancetype _Nonnull)eventEndLocationUpdatedWithRide:(RARideDataModel *_Nonnull)ride modelId:(NSNumber *_Nonnull)modelId;
+ (instancetype _Nonnull)eventRiderCommentUpdatedWithRide:(RARideDataModel *_Nonnull)ride modelId:(NSNumber *_Nonnull)modelId;
+ (instancetype _Nonnull)eventUpgradeRequestAcceptedWithRide:(RARideDataModel *_Nonnull)ride modelId:(NSNumber *_Nonnull)modelId;
+ (instancetype _Nonnull)eventUpgradeRequestDeclineByRiderWithRide:(RARideDataModel *_Nonnull)ride modelId:(NSNumber *_Nonnull)modelId;
+ (instancetype _Nonnull)eventUpdateRiderLocationWithLatitude:(NSNumber *_Nonnull)latitude longitude:(NSNumber *_Nonnull)longitude modelId:(NSNumber *_Nonnull)modelId;
+ (instancetype _Nonnull)eventAdminCancelledRide:(RARideDataModel *_Nonnull)ride modelId:(NSNumber *_Nonnull)modelId;

- (void)incrementModelId;
/**
 Used by EventStubModel to attach expiration based on launchDate

 @param launchDate date when eventStubModel is expected to be sent
 */
- (void)updateRideAcceptanceWithLaunchDate:(NSDate *_Nonnull)launchDate;

@end
