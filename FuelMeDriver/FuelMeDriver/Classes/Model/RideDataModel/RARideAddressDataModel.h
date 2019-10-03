//
//  RideAddress.h
//  RideDriver
//
//  Created by Carlos Alcala on 7/21/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RABaseDataModel.h"

@interface RARideAddressDataModel : RABaseDataModel

@property (nonatomic, readonly) NSNumber *latitude;
@property (nonatomic, readonly) NSNumber *longitude;
@property (nonatomic) NSString *address;
@property (nonatomic) NSString *zipCode;
@property (nonatomic, readonly) NSString *fullAddress;
@property (nonatomic, readonly) NSString *primaryAddress;
@property (nonatomic, readonly) CLLocation *location;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly) BOOL isValid;

- (void)setLocationByCoordinate:(CLLocationCoordinate2D)coordinate;

@end
