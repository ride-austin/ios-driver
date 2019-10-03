//
//  RAPickupHint.m
//  Ride
//
//  Created by Roberto Abreu on 9/6/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RAPickupHint.h"

#import "GoogleMapsManager.h"

@implementation RAPickupHint

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{ @"name" : @"name",
              @"areaPolygon" : @"areaPolygon",
              @"designatedPickups" : @"designatedPickups"
              };
}

+ (NSValueTransformer *)areaPolygonJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[RACoordinate class]];
}

+ (NSValueTransformer *)designatedPickupsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[RADesignatedPickup class]];
}

- (BOOL)containsCoordinate:(CLLocationCoordinate2D)coordinate {
    NSArray<CLLocation *> *locations = [self.areaPolygon valueForKey:@"location"];
    return locations && [GMSPath coordinate:coordinate isInsidePathFromLocations:locations];
}

@end
