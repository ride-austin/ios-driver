//
//  RAMenuItem.m
//  RideDriver
//
//  Created by Roberto Abreu on 19/1/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RAMenuItem.h"

@implementation RAMenuItem

- (instancetype)initWithTitle:(NSString *)title iconPath:(NSString *)iconPath targetClassIdentifier:(NSString *)targetClassIdentifier objectContext:(id)objectContext storyboardIdentifier:(NSString *)storyBoard {
    if (self = [super init]) {
        self.title = title;
        self.iconPath = iconPath;
        self.targetClassIdentifier = targetClassIdentifier;
        self.objectContext = objectContext;
        self.storyboardIdentifier = storyBoard;
        self.behaviour = Push;
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title iconPath:(NSString *)iconPath targetClassIdentifier:(NSString *)targetClassIdentifier objectContext:(id)objectContext {
    return [self initWithTitle:title iconPath:iconPath targetClassIdentifier:targetClassIdentifier objectContext:objectContext storyboardIdentifier:@"Main"];
}

- (BOOL)isLocalIcon {
    if (self.iconPath) {
        return [UIImage imageNamed:self.iconPath] != nil;
    }
    return NO;
}

- (NSURL *)iconURL {
    return [NSURL URLWithString:self.iconPath];
}

@end
