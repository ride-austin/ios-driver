//
//  SettingsSection.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 12/16/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SettingsItem.h"

typedef NS_ENUM(NSUInteger, SectionType) {
    SectionTypeNormal
};

@interface SettingsSection : NSObject

@property (nonatomic) NSString *title;
@property (nonatomic) NSMutableArray<SettingsItem *> *items;
@property (nonatomic) SectionType type;

+ (instancetype)sectionWithTitle:(NSString *)title;
- (void)addObject:(id)object;
- (NSString *)cellIdentifier;
- (NSInteger)rowCount;

@end
