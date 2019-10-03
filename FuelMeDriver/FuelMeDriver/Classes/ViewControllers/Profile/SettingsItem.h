//
//  SettingsItem.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 12/16/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^senderBlock)(UITableViewCell *sender);

@interface SettingsItem : NSObject

@property (nonatomic) NSString *title;
@property (nonatomic) NSString *subTitle;
@property (nonatomic) NSURL *mainURL;
@property (nonatomic) NSURL *secondaryURL;
@property (nonatomic, copy) senderBlock didSelectBlock;
@property (nonatomic) NSString *cellIdentifier;
@property (nonatomic) UITableViewCellStyle cellStyle;
@property (nonatomic) UITableViewCellAccessoryType accessoryType;
@property (nonatomic, assign) BOOL featured;

/**
 *  @brief SettingsViewController will check mainURL, secondaryURL then didSelectBlock which ever is valid first
 */
+ (instancetype)itemWithTitle:(NSString *)title
                      mainURL:(NSURL *)mainURL;
+ (instancetype)itemWithTitle:(NSString *)title
                     subtitle:(NSString *)subtitle
                      mainURL:(NSURL *)mainURL;
+ (instancetype)itemWithTitle:(NSString *)title
                      mainURL:(NSURL *)mainURL
                 secondaryURL:(NSURL *)secondaryURL;
+ (instancetype)itemWithTitle:(NSString *)title
               didSelectBlock:(senderBlock)didSelectBlock;

@end
