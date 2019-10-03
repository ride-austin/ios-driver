//
//  DriverRideEarnings.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 6/8/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RABaseDataModel.h"
#import "RideFareDataModel.h"

@interface DriverRideEarnings : RABaseDataModel

@property (nonatomic, readonly) NSArray *content;

@end

@interface DriverRideEarnings (TestData)

+ (instancetype)earningsWithRides:(NSArray<RideFareDataModel *> *)rideFares;

@end
