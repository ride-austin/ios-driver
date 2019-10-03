//
//  AppDelegate+LoadData.m
//  RideDriver
//
//  Created by Carlos Alcala on 1/24/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "AppDelegate+LoadData.h"
#import "RACarManager.h"

@implementation AppDelegate (LoadData)

- (void)setupCarsData {
    [RACarManager cars];
}

@end
