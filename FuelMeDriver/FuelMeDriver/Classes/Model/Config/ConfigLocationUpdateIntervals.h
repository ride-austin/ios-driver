//
//  ConfigLocationUpdateIntervals.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 6/28/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RABaseDataModel.h"

@interface ConfigLocationUpdateIntervals : RABaseDataModel

NS_ASSUME_NONNULL_BEGIN
/// speed in m/s to be considered moving
@property (nonatomic, readonly) NSNumber *movementSpeed;
@property (nonatomic, readonly) NSNumber *whenOnTrip;
@property (nonatomic, readonly) NSNumber *whenOnlineAndMoving;
@property (nonatomic, readonly) NSNumber *whenOnlineAndNotMoving;
NS_ASSUME_NONNULL_END

@end
