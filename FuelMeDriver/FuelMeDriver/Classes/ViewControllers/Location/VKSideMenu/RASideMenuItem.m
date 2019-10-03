//
//  RASideMenuItem.m
//  Ride
//
//  Created by Theodore Gonzalez on 8/27/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RASideMenuItem.h"

@implementation RASideMenuItem

- (instancetype)initWithTitle:(NSString *)title iconName:(id)iconName block:(DidTapSideMenu)block {
    if (self = [super init]) {
        _title = title;
        _iconName = iconName;
        _didTapBlock = block;
    }
    return self;
}

+ (instancetype)itemWithTitle:(NSString *)title iconName:(id)iconName block:(DidTapSideMenu)block {
    return [[self alloc] initWithTitle:title iconName:iconName block:block];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %@ %@", NSStringFromClass(self.class), self.title, self.iconName];
}

@end
