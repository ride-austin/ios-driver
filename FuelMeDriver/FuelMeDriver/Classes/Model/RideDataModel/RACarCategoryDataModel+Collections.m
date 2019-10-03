//
//  RACarCategoryDataModel+Collections.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 9/19/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RACarCategoryDataModel+Collections.h"

@implementation RACarCategoryDataModel (Collections)

@end

#import "NSString+CityCarCategory.h"
@implementation NSArray (CityCarCategoryDataModel)
/**
 from [RACarCategoryDataModel] to NSString joined by ","
 */
- (NSString *)carCategoriesString {
    if (self.count > 1) {
        NSAssert([self.firstObject isKindOfClass:RACarCategoryDataModel.class], @"this method requires RACarCategoryDataModel");
    }
    return [[self valueForKey:@"carCategory"] stringArrayToString];
}

/**
 from [RACarCategoryDataModel] to NSString joined by ", "
 */
- (NSString *)titlesString {
    if (self.count > 1) {
        NSAssert([self.firstObject isKindOfClass:RACarCategoryDataModel.class], @"this method requires RACarCategoryDataModel");
    }
    return [[self valueForKey:@"title"] componentsJoinedByString:@", "];
}

/**
 from [RACarCategoryDataModel] to NSString joined by " + "
 */
- (NSString *)titlesStringPlus {
    if (self.count > 1) {
        NSAssert([self.firstObject isKindOfClass:RACarCategoryDataModel.class], @"this method requires RACarCategoryDataModel");
    }
    return [[self valueForKey:@"title"] componentsJoinedByString:@" + "];
}
/**
 from [NSString] to [RACarCategoryDataModel]
 */
- (NSArray<RACarCategoryDataModel *> *)stringToCarCategories {
    NSMutableArray<RACarCategoryDataModel *> *carCategories = [NSMutableArray new];
    for (NSString *carString in self) {
        NSAssert([carString isKindOfClass:NSString.class], @"this method requires NSString");
        RACarCategoryDataModel *carCategory = carString.cityCarCategory;
        if (carCategory) {
            [carCategories addObject:carCategory];
        } else {
            DBLog(@"%@ is not found", carString);
        }
    }
    return carCategories;
}

/**
 
 */
- (NSString *)stringArrayToString {
    if (self.count > 1) {
        NSAssert([self.firstObject isKindOfClass:NSString.class], @"this method requires NSString");
    }
    return [self componentsJoinedByString:@","];
}
@end


@implementation NSString (CityCarCategoryDataModel)

/**
 from NSString to [RACarCategoryDataModel]
 */
- (NSArray<RACarCategoryDataModel *> *)stringToCarCategories {
    NSArray<NSString *> *strings = [self componentsSeparatedByString:@","];
    return strings.stringToCarCategories;
}

@end

@implementation NSSet (CityCarCategoryDataModel)

- (NSString *)stringToTitlesStringPlus {
    return self.allObjects.stringToCarCategories.titlesStringPlus;
}

- (NSString *)stringToTitlesString {
    return self.allObjects.stringToCarCategories.titlesString;
}

@end
