//
//  ConfigGeoCoding.m
//  Ride
//
//  Created by Theodore Gonzalez on 11/28/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "ConfigGeoCoding.h"

@implementation ConfigGeoCoding

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
              @"queryHints" : @"queryHints",
              @"pickupHints" : @"pickupHints"
            };
}

+ (NSValueTransformer *)queryHintsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[RADestination class]];
}

+ (NSValueTransformer *)pickupHintsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[RAPickupHint class]];
}

@end
