//
//  SettingsItem.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 12/16/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "SettingsItem.h"

#import "NSObject+className.h"

@implementation SettingsItem

+ (instancetype)itemWithTitle:(NSString *)title
                     mainURL:(NSURL *)mainURL {
    
    return [self itemWithTitle:title
                      subtitle:nil
                       mainURL:mainURL
                  secondaryURL:nil
                didSelectBlock:nil];
}

+ (instancetype)itemWithTitle:(NSString *)title
                    subtitle:(NSString *)subtitle
                     mainURL:(NSURL *)mainURL {
    
    return [self itemWithTitle:title
                      subtitle:subtitle
                       mainURL:mainURL
                  secondaryURL:nil
                didSelectBlock:nil];
}

+ (instancetype)itemWithTitle:(NSString *)title
                     mainURL:(NSURL *)mainURL
                secondaryURL:(NSURL *)secondaryURL {
    
    return [self itemWithTitle:title
                      subtitle:nil
                       mainURL:mainURL
                  secondaryURL:secondaryURL
                didSelectBlock:nil];
}

+ (instancetype)itemWithTitle:(NSString *)title
              didSelectBlock:(senderBlock)didSelectBlock {
    return [self itemWithTitle:title subtitle:nil
                       mainURL:nil
                  secondaryURL:nil
                didSelectBlock:didSelectBlock];
}

+ (instancetype)itemWithTitle:(NSString *)title
                    subtitle:(NSString *)subtitle
                     mainURL:(NSURL *)mainURL
                secondaryURL:(NSURL *)secondaryURL
              didSelectBlock:(senderBlock)didSelectBlock {
    
    SettingsItem *item = [[SettingsItem alloc] initWithTitle:title
                                                    subtitle:subtitle
                                                     mainURL:mainURL
                                                secondaryURL:secondaryURL
                                           andSelectionBlock:didSelectBlock];
    return item;
}

- (instancetype)initWithTitle:(NSString *)title
                    subtitle:(NSString *)subtitle
                     mainURL:(NSURL *)mainURL
                secondaryURL:(NSURL *)secondaryURL
           andSelectionBlock:(senderBlock)didSelectBlock {
    self = [super init];
    if (self) {
        self.title          = title;
        self.subTitle       = subtitle;
        self.mainURL        = mainURL;
        self.secondaryURL   = secondaryURL;
        self.didSelectBlock = didSelectBlock;
        self.cellIdentifier = @"SettingsCell";
        self.cellStyle      = UITableViewCellStyleValue1;
        self.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
    }
    if ([self.title isKindOfClass:[NSString class]]) {
        return self;
    } else {
        return nil;
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ title:%@\nsubtitle: %@\nmainURL:%@\nsecondaryURL:%@\nhasBlock:%@>",
            self.className,
            self.title,
            self.subTitle,
            self.mainURL,
            self.secondaryURL,
            self.didSelectBlock?@"YES":@"NO"];
}

@end
