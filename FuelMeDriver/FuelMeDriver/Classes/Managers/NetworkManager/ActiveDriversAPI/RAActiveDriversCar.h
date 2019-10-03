//
//  RAActiveDriversCar.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 9/7/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RABaseDataModel.h"

@interface RAActiveDriversCarDriver : MTLModel <MTLJSONSerializing>
//@property (nonatomic, readonly) NSNumber *modelID; //unused
@property (nonatomic, readonly) RABaseDataModel *user;
@end

@interface RAActiveDriversCar : MTLModel <MTLJSONSerializing>
@property (nonatomic, readonly) NSNumber *course;
@property (nonatomic, readonly) RAActiveDriversCarDriver *driver;
@property (nonatomic, readonly) NSNumber *latitude;
@property (nonatomic, readonly) NSNumber *longitude;
//@property (nonatomic, readonly) NSString *status; //unused
- (CLLocationCoordinate2D)coordinate;
@end
