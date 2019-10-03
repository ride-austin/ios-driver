//
//  RASideMenuItem.h
//  Ride
//
//  Created by Theodore Gonzalez on 8/27/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^DidTapSideMenu)(UITableViewCell * _Nonnull cell);

@interface RASideMenuItem : NSObject

@property (nonatomic, copy, readonly, nonnull) NSString *title;
@property (nonatomic, copy, readonly, nonnull) id iconName;
@property (nonatomic, copy, nullable) UIColor *iconColor;
@property (nonatomic, copy, nullable) NSString *viewControllerName;
@property (nonatomic, copy, nullable) DidTapSideMenu didTapBlock;

+ (instancetype _Nonnull )itemWithTitle:(NSString *_Nonnull)title iconName:(NSString *_Nonnull)iconName block:(DidTapSideMenu _Nullable )block;

@end
