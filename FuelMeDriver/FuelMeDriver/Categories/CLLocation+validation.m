//
//  CLLocation+validation.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 7/29/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "CLLocation+validation.h"

@implementation CLLocation (validation)
-(BOOL)isValid {
    return (CLLocationCoordinate2DIsValid(self.coordinate) && self.coordinate.longitude != 0 && self.coordinate.latitude != 0);
}
@end
