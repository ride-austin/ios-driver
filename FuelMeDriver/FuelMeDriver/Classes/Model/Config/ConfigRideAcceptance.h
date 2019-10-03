//
//  ConfigRideAcceptance.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 6/28/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RABaseDataModel.h"

@interface ConfigRideAcceptance : RABaseDataModel

NS_ASSUME_NONNULL_BEGIN
@property (nonatomic, readonly) NSNumber *acceptancePeriod;
@property (nonatomic, readonly) NSNumber *allowancePeriod;
NS_ASSUME_NONNULL_END

@end
