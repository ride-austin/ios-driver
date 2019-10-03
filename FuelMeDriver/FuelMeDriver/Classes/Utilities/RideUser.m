//
//  RideUser.m
//  RideAustin.com
//
//  Created by Tyson Bunch on 9/19/12.
//  Copyright (c) 2012 FuelMe, Inc. All rights reserved.
//

#import "RideUser.h"

static Car* car;

@implementation RideUser

+ (Car*) car {
    return car;
}

+ (void)setCar: (Car*)value {
    car = value;
}

@end

