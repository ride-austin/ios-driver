//
//  RAActiveDriver.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 10/17/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "Car.h"
#import "RABaseDataModel.h"
#import "RADriverDataModel.h"
#import "RARideDataModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, RAActiveDriverStatus) {
    RAActiveDriverStatusInactive    = 1,
    RAActiveDriverStatusAvailable   = 2,
    RAActiveDriverStatusRiding      = 3,
    RAActiveDriverStatusRequested   = 7,
    RAActiveDriverStatusAway        = 8
};

@interface RAActiveDriver : RABaseDataModel

@property (nonatomic, readonly) RAActiveDriverStatus status;
@property (nonatomic, readonly) RARideDataModel * __nullable ride;
@property (nonatomic, readonly) RADriverDataModel *driver;
@property (nonatomic, readonly) Car *selectedCar;
@property (nonatomic, readonly) NSArray<NSString *> *onlineCarCategories;

@end

NS_ASSUME_NONNULL_END
