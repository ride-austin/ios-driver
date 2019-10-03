//
//  CarCategoriesManager.m
//  Ride
//
//  Created by Roberto Abreu on 19/09/2016.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "CarCategoriesManager.h"

#import "ConfigurationManager.h"
#import "NSString+CityCarCategory.h"
#import "NetworkManager.h"
#import "RAJSONAdapter.h"

static NSString *kReloadCategoriesImageNotification = @"kReloadCategoriesImageNotification";

@interface CarCategoriesManager()
@end
@implementation CarCategoriesManager

+ (void)saveCategoryIcon:(RACarCategoryDataModel*)category{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,  0ul);
    dispatch_async(queue, ^{
        NSData *data = [NSData dataWithContentsOfURL:category.iconURL];
        
        NSString *documentDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *fullPath = [documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"category/%@",category.iconName]];
        
        NSError *error = nil;
        [data writeToFile:fullPath options:NSDataWritingAtomic error:&error];
        if (error) {
            DBLog(@"Error Category : %@", error.localizedDescription);
        }
    });
}

+ (void)prefetchCarCategoryIconsFromCarTypes:(NSArray<RACarCategoryDataModel *>*)allCarTypes {
    for (RACarCategoryDataModel *category in allCarTypes) {
        NSString *iconName = [category.iconURL.absoluteString lastPathComponent];
        NSString *documentDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *fullPath = [documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"category/%@",iconName]];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:[documentDirectory stringByAppendingPathComponent:@"category"]]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:[documentDirectory stringByAppendingPathComponent:@"category"] withIntermediateDirectories:NO attributes:nil error:nil];
        }
        
        //category.iconURL with "" value ~ Local Image
        if (![iconName isEqualToString:@""] && ![[NSFileManager defaultManager] fileExistsAtPath:fullPath]) {
            [CarCategoriesManager saveCategoryIcon:category];
        }
    }
}

+ (UIImage *)carIconByCategoryName:(NSString *)categoryName {
    return [self categoryByName:categoryName].icon;
}

+ (RACarCategoryDataModel *)categoryByName:(NSString *)categoryName {
    for (RACarCategoryDataModel *category in [ConfigurationManager shared].global.carTypes) {
        if ([categoryName isEqualToString:category.carCategory]) {
            return category;
        }
    }
    return nil;
}
@end





