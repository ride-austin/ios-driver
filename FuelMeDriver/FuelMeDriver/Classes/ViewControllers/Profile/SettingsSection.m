//
//  SettingsSection.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 12/16/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "SettingsSection.h"

@implementation SettingsSection

+ (instancetype)sectionWithTitle:(NSString *)title {
    return [[self alloc] initWithTitle:title
                                  type:SectionTypeNormal];
}

- (instancetype)initWithTitle:(NSString *)title type:(SectionType)type {
    self = [super init];
    if (self) {
        self.title  = title;
        self.type   = type;
        self.items  = [NSMutableArray new];
    }
    return self;
}

- (void)addObject:(id)object {
    NSAssert(object != nil, @"SettingsSection cannot add nil");
    if (object) {
        [self.items addObject:object];
    }
}

- (NSString *)cellIdentifier {
    switch (self.type) {
        case SectionTypeNormal:
            return @"SettingsCell";
    }
}

- (NSInteger)rowCount {
    switch (self.type) {
        case SectionTypeNormal:
            return self.items.count;
    }
    return self.items.count;
}

@end
