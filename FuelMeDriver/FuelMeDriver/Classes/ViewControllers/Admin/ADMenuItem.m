//
//  ADMenuItem.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 8/16/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "ADMenuItem.h"

@implementation ADMenuItem

+ (instancetype)itemWithTitle:(NSString *)title andDidTapCellBlock:(DidTapCell)didTapCellBlock {
    return [[self alloc] initWithTitle:title andDidTapCellBlock:didTapCellBlock];
}

- (instancetype)initWithTitle:(NSString *)title andDidTapCellBlock:(DidTapCell)didTapCellBlock {
    if ([super init]) {
        _title = title;
        _didTapCellBlock = didTapCellBlock;
    }
    return self;
}

@end
