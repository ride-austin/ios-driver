//
//  RARideUpgrade.m
//  RideDriver
//
//  Created by Roberto Abreu on 6/7/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RARideUpgrade.h"

@implementation RARideUpgrade

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{ @"categoryName"   : @"carCategory",
              @"upgradeTargets" : @"validUpgrades" };
}

@end
