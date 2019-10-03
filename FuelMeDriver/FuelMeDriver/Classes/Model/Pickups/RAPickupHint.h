//
//  RAPickupHint.h
//  Ride
//
//  Created by Roberto Abreu on 9/6/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RABaseDataModel.h"
#import "RACoordinate.h"
#import "RADesignatedPickup.h"

@interface RAPickupHint : RABaseDataModel

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSArray<RACoordinate*> *areaPolygon;
@property (nonatomic, readonly) NSArray<RADesignatedPickup*> *designatedPickups;

- (BOOL)containsCoordinate:(CLLocationCoordinate2D)coordinate;

@end
