//
//  ConfigRideUpgrade.h
//  RideDriver
//
//  Created by Roberto Abreu on 6/7/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RARideUpgrade.h"

@interface ConfigRideUpgrade : MTLModel <MTLJSONSerializing>

@property (nonatomic,strong) NSArray<RARideUpgrade*>* ridesUpgrade;

- (RARideUpgrade*)rideUpgradeFromCarCategoryName:(NSString*)categoryName;

@end
