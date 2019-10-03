//
//  SurgeArea.m
//  RideDriver
//
//  Created by Abdul Rehman on 18/08/2016.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "SurgeArea.h"

@interface SurgeArea ()
{
    GMSPath *_boundary;
}
@property (nonatomic, strong) NSNumber *centerLat;
@property (nonatomic, strong) NSNumber *centerLong;
@property (nonatomic, strong) NSString *csvGeometry;
@end

@implementation SurgeArea

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    NSDictionary *JSONKeyPaths =
    @{@"name" : @"name",
      @"csvGeometry" : @"csvGeometry",
      @"centerLat"   : @"centerPointLat",
      @"centerLong"  : @"centerPointLng",
      @"carCategoriesFactors":@"carCategoriesFactors"};
    return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:JSONKeyPaths];
}

#pragma mark - ReadOnly Properties

- (GMSPath *)boundary {
    if (!_boundary) {
        _boundary = [super pathFromString:self.csvGeometry];
    }
    return _boundary;
}

- (CLLocationCoordinate2D)centerPoint {
    return CLLocationCoordinate2DMake(self.centerLat.doubleValue, self.centerLong.doubleValue);
}

- (BOOL)hasSurgeGeometry {
    return self.boundary != nil;
}

@end
