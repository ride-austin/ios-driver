//
//  RACarCategoryDataModel+Collections.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 9/19/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RACarCategoryDataModel.h"

@interface RACarCategoryDataModel (Collections)

@end

@interface NSArray (CityCarCategoryDataModel)

/**
 from [RACarCategoryDataModel] to NSString joined by ","
 */
- (NSString *)carCategoriesString;

/**
 from [RACarCategoryDataModel] to NSString joined by ","
 */
- (NSString *)titlesString;

/**
 from [RACarCategoryDataModel] to NSString joined by " + "
 */
- (NSString *)titlesStringPlus;

/**
 from [NSString] to [RACarCategoryDataModel]
 */
- (NSArray<RACarCategoryDataModel *> *)stringToCarCategories;

/**
 from [NSString] to String
 */
- (NSString *)stringArrayToString;
@end


@interface NSString (CityCarCategoryDataModel)

/**
 from NSString to [RACarCategoryDataModel]
 */
- (NSArray<RACarCategoryDataModel *> *)stringToCarCategories;

@end

@interface NSSet (CityCarCategoryDataModel)

/**
 from [NSString] to [RACarCategoryDataModel] to NSString joined by " + "
 */
- (NSString *)stringToTitlesStringPlus;

/**
 from [NSString] to [RACarCategoryDataModel] to NSString joined by ", "
 */
- (NSString *)stringToTitlesString;
@end
