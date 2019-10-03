//
//  ConfigRideUpgrade.m
//  RideDriver
//
//  Created by Roberto Abreu on 6/7/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "ConfigRideUpgrade.h"

@implementation ConfigRideUpgrade

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{ @"ridesUpgrade" : @"variants" };
}

+ (NSValueTransformer *)ridesUpgradeJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[RARideUpgrade class]];
}

- (RARideUpgrade *)rideUpgradeFromCarCategoryName:(NSString *)categoryName {
    for (RARideUpgrade *rideUpgrade in self.ridesUpgrade) {
        if ([rideUpgrade.categoryName isEqualToString:categoryName]) {
            return rideUpgrade;
        }
    }
    return nil;
}

@end
