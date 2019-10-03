//
//  RATableItem.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 1/19/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RATableItem.h"

@implementation RATableItem

- (instancetype)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle andSelectionBlock:(senderBlock)didSelectBlock {
    self = [super init];
    if (self) {
        self.title          = title;
        self.subTitle       = subtitle;
        self.didSelectBlock = didSelectBlock;
        self.cellStyle      = UITableViewCellStyleValue1;
        self.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
    }
    if ([self.title isKindOfClass:[NSString class]]) {
        return self;
    } else {
        return nil;
    }
}

+ (instancetype)itemWithTitle:(NSString *)title didSelectBlock:(senderBlock)didSelectBlock {
    return [self itemWithTitle:title subtitle:nil didSelectBlock:didSelectBlock];
}

+ (instancetype)itemWithTitle:(NSString *)title subtitle:(NSString *)subtitle didSelectBlock:(senderBlock)didSelectBlock {
    RATableItem *item = [[RATableItem alloc] initWithTitle:title subtitle:subtitle andSelectionBlock:didSelectBlock];
    return item;
}

@end
