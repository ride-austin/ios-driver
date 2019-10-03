//
//  RADriverType.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 6/16/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RABaseDataModel.h"
#import "DriverType.h"

@interface RADriverType : RABaseDataModel

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSArray<NSString *> *availableInCategories;

- (DriverType)driverType;

@end

