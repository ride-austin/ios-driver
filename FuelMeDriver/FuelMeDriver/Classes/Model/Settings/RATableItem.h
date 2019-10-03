//
//  RATableItem.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 1/19/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^senderBlock)(UITableViewCell *sender);

@interface RATableItem : NSObject

@property (nonatomic) NSString *title;
@property (nonatomic) NSString *subTitle;
@property (nonatomic, copy) senderBlock didSelectBlock;

@property (nonatomic) NSString *cellIdentifier;
@property (nonatomic) UITableViewCellStyle cellStyle;
@property (nonatomic) UITableViewCellAccessoryType accessoryType;

+ (instancetype)itemWithTitle:(NSString *)title didSelectBlock:(senderBlock)didSelectBlock;

@end
