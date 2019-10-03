//
//  CarTypeViewModel.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 9/18/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "CarTypeViewModel.h"

#import "RACarCategoryDataModel.h"

@interface CarTypeViewModel()

@property (nonatomic, readonly) RACarCategoryDataModel *model;

@end

@implementation CarTypeViewModel

- (instancetype)initWithCategory:(RACarCategoryDataModel *)category {
    if (self = [super init]) {
        _model = category;
    }
    return self;
}

+ (instancetype)viewModelWithCategory:(RACarCategoryDataModel *)category {
    return [[self alloc] initWithCategory:category];
}

- (NSString *)carCategory {
    return self.model.carCategory;
}

- (NSString *)displayName {
    return self.model.title;
}

- (NSURL *)iconURL {
    return self.model.iconURL;
}

- (UIImage *)backgroundImage {
    return [UIImage imageNamed:self.backgroundImageName];
}

- (NSString *)backgroundImageName {
    if (self.isSelected) {
        return [NSString stringWithFormat:@"ride-type-box-active-bg"];
    } else {
        return [NSString stringWithFormat:@"ride-type-box-inactive-bg"];
    }
}

- (UIColor *)tintColor {
    return self.isActive ? [UIColor blackColor] : [UIColor lightGrayColor];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ isActive:%d isSelected:%d %@",NSStringFromClass(self.class), self.isActive, self.isSelected, self.carCategory];
}

- (BOOL)isEqual:(CarTypeViewModel *)object {
    return [object isKindOfClass:self.class]
    && [self.carCategory isEqualToString:object.carCategory]
    && self.isSelected == object.isSelected;
}

@end
