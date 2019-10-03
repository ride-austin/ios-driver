//
//  NSString+CityCarCategory.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 9/19/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "NSString+CityCarCategory.h"

#import "ConfigurationManager.h"

@implementation NSString (CityCarCategory)

- (RACarCategoryDataModel *)cityCarCategory {
    for (RACarCategoryDataModel *category in [ConfigurationManager shared].global.carTypes) {
        if ([self isEqualToString:category.carCategory]) {
            return category;
        }
    }
    return nil;
}

@end

