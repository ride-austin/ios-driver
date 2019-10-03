//
//  RACarCategoryConfigurationModel.m
//  Ride
//
//  Created by Theodore Gonzalez on 5/30/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RACarCategoryConfigurationModel.h"

@implementation RACarCategoryConfigurationModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:[self JSONKeyPaths]];
}

+JSONKeyPaths {
    return
    @{
      @"disableCancellationFee" : @"disableCancellationFee",
      @"supportsAreaQueue"      : @"supportAreaQueue"
      };
}

@end
