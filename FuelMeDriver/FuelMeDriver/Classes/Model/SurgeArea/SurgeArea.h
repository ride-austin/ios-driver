//
//  SurgeArea.h
//  RideDriver
//
//  Created by Abdul Rehman on 18/08/2016.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "RABaseDataModel.h"

@interface SurgeArea : RABaseDataModel

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSDictionary<NSString *,NSNumber *> *carCategoriesFactors;

- (GMSPath *)boundary;
- (CLLocationCoordinate2D)centerPoint;
- (BOOL)hasSurgeGeometry;

@end
