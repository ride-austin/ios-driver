//
//  RAPickupManager.h
//  Ride
//
//  Created by Roberto Abreu on 9/6/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RADesignatedPickup.h"

@interface RAPickupManager : NSObject

+ (BOOL)isLocationInsidePickupHint:(CLLocation *)location;
+ (CLLocation *)refinePickupLocation:(CLLocation *)location;

@end
