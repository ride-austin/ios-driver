//
//  ConfigGeoCoding.h
//  Ride
//
//  Created by Theodore Gonzalez on 11/28/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RADestination.h"
#import "RAPickupHint.h"

#import <Mantle/Mantle.h>

@interface ConfigGeoCoding : MTLModel <MTLJSONSerializing>

@property (nonatomic) NSArray<RADestination *> *queryHints;
@property (nonatomic) NSArray<RAPickupHint *> *pickupHints;

@end
