//
//  RADriverType.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 6/16/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RADriverType.h"

@implementation RADriverType

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{ @"name" : @"name",
              @"availableInCategories" : @"availableInCategories"
            };
}

- (DriverType)driverType {
    if ([self.name isEqualToString:@"WOMEN_ONLY"]) {
        return DriverTypeFemaleDriver;
    }
    else if ([self.name isEqualToString:@"DIRECT_CONNECT"]) {
        return DriverTypeDirectConnect;
    }
    else if ([self.name isEqualToString:@"FINGERPRINTED"]) {
        return DriverTypeFingerPrinted;
    }
    return DriverTypeUnspecified;
}

@end
