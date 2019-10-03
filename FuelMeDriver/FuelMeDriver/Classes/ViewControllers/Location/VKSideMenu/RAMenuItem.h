//
//  RAMenuItem.h
//  RideDriver
//
//  Created by Roberto Abreu on 19/1/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, RAMenuItemBehaviour) {
    Push,
    Present
};

@interface RAMenuItem : NSObject

@property (nonatomic) NSString *title;
@property (nonatomic) NSString *iconPath;
@property (nonatomic) NSString *targetClassIdentifier;
@property (nonatomic) id objectContext;
@property (nonatomic) NSString *storyboardIdentifier;
@property (nonatomic, readonly) BOOL isLocalIcon;
@property (nonatomic, readonly) NSURL *iconURL;
@property (nonatomic) RAMenuItemBehaviour behaviour;
@property (nonatomic) BOOL shouldAppearLast;

- (instancetype)initWithTitle:(NSString *)title iconPath:(NSString *)iconPath targetClassIdentifier:(NSString *)targetClassIdentifier objectContext:(id)objectContext storyboardIdentifier:(NSString *)storyBoard;
- (instancetype)initWithTitle:(NSString *)title iconPath:(NSString *)iconPath targetClassIdentifier:(NSString *)targetClassIdentifier objectContext:(id)objectContext;

@end
