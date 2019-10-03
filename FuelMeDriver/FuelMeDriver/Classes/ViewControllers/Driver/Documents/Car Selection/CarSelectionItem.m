//
//  CarSelectionItem.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 10/2/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "CarSelectionItem.h"

@implementation CarSelectionItem

- (instancetype)initWithTitle:(NSString *)title andDidTapCarBlock:(DidTapCar)didTapCarBlock {
    if (self = [super init]) {
        _title = title;
        _didTapCarBlock = didTapCarBlock;
    }
    return self;
}

+ (instancetype)itemWithTitle:(NSString *)title andDidTapCarBlock:(DidTapCar)didTapCarBlock {
    return [[self alloc] initWithTitle:title andDidTapCarBlock:didTapCarBlock];
}

@end
