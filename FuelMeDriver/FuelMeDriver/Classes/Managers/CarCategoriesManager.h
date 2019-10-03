//
//  CarCategoriesManager.h
//  Ride
//
//  Created by Roberto Abreu on 19/09/2016.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RACarCategoryDataModel.h"

@interface CarCategoriesManager : NSObject

+ (void)prefetchCarCategoryIconsFromCarTypes:(NSArray<RACarCategoryDataModel *>*)allCarTypes;
+ (UIImage*)carIconByCategoryName:(NSString*)categoryName;

@end



