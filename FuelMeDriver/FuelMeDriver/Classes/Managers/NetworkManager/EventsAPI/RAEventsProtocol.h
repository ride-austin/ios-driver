//
//  RAEventsProtocol.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 7/18/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RideDriverEnums.h"

@protocol RAHandShakeEventProtocol <NSObject>
@required
- (NSTimeInterval)remainingHandShakeExpiration;
- (NSNumber *)rideId;
@end

@class RARideDataModel;
@protocol RARideRequestProtocol <NSObject>
@required
- (RARideDataModel *)ride;
- (RARideDataModel *)nextRide;
- (NSTimeInterval)remainingAcceptanceExpiration;
- (NSTimeInterval)remainingAcknowledgeExpiration;
- (BOOL)isStackedRide;
@end

@class CLLocation;
@protocol RARiderLocationUpdateProtocol <NSObject>
@required
@property (nonatomic, copy, readonly) NSDate *timeStamp;
- (CLLocation *)location;
@end

@protocol RAInactiveEventProtocol <NSObject>
@required
- (InactiveEventSource)source;
- (NSString *)reason;
@end

@protocol RAQueueEventProtocol <NSObject>
@required
- (NSString *)areaQueueName;
@end

@protocol RAQueueEventPenaltyProtocol <NSObject>
@required
- (NSString *)message;
@end

@protocol RACarCategoryChangedEventProtocol <NSObject>
@required
- (CarCategoryChangeSource)categoryChangeSource;
- (NSArray<NSString *> *)missedCategories;
@end

@class SurgeArea;
@protocol RASurgeAreaEventProtocol <NSObject>
@required
- (NSArray<SurgeArea *> *)surgeAreasUpdated;
@end

@protocol RARideUpgradeEventProtocol <NSObject>
@required
- (NSNumber *)rideId;
@end
