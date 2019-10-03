//
//  RideUser.h
//  RideAustin.com
//
//  Created by Tyson Bunch on 9/19/12.
//  Copyright (c) 2012 FuelMe, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Car.h"

typedef void(^SignOutBlock)(BOOL);

@interface RideUser : NSObject

+ (Car*)car;
+ (void)setCar:(Car*)value;

@end
