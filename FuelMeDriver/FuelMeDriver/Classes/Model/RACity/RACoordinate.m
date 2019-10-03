//
//  RACoordinate.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 11/28/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "RACoordinate.h"

@interface RACoordinate()

@property (nonatomic) NSNumber *lat;
@property (nonatomic) NSNumber *lng;

@end

@implementation RACoordinate

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
              @"lat" : @"lat",
              @"lng" : @"lng"
            };
}

- (CLLocation *)location {
    return [[CLLocation alloc] initWithLatitude:self.lat.doubleValue longitude:self.lng.doubleValue];
}

@end
