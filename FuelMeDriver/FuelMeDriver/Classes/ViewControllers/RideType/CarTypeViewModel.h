//
//  CarTypeViewModel.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 9/18/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RACarCategoryDataModel;

@interface CarTypeViewModel : NSObject

@property (nonatomic) BOOL isActive;
@property (nonatomic) BOOL isSelected;

+ (instancetype)viewModelWithCategory:(RACarCategoryDataModel *)category;
- (NSString *)carCategory;
- (NSString *)displayName;
- (NSURL *)iconURL;
- (UIImage *)backgroundImage;
- (UIColor *)tintColor;

@end
