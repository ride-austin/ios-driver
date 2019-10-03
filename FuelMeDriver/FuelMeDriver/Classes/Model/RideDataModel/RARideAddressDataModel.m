//
//  RideAddress.m
//  RideDriver
//
//  Created by Carlos Alcala on 7/21/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "RARideAddressDataModel.h"

@implementation RARideAddressDataModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{ @"address" : @"address",
              @"zipCode" : @"zipCode"};
}

- (NSString*)fullAddress{
    if (self.address && self.zipCode) {
        return [NSString stringWithFormat:@"%@, %@", self.address, self.zipCode];
    }
    
    if (self.address) {
        return self.address;
    }
    
    return @"";
}

- (NSString *)primaryAddress{
    NSArray *chunks = [self.address componentsSeparatedByString: @","];
    return (chunks.count > 0) ? chunks.firstObject : self.address;
}

- (CLLocation *)location {
    return [[CLLocation alloc] initWithLatitude:[self.latitude doubleValue] longitude:[self.longitude doubleValue]];
}

- (CLLocationCoordinate2D)coordinate {
    return CLLocationCoordinate2DMake([self.latitude doubleValue], [self.longitude doubleValue]);
}

- (BOOL)isValid {
    return CLLocationCoordinate2DIsValid(self.coordinate) && self.latitude.doubleValue != 0 && self.longitude.doubleValue != 0;
}

#pragma mark - Convenience Methods

- (void)setLocationByCoordinate:(CLLocationCoordinate2D)coordinate {
    _latitude = [NSNumber numberWithDouble:coordinate.latitude];
    _longitude = [NSNumber numberWithDouble:coordinate.longitude];
}

@end
