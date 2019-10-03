//
//  RAAlertNotificationOption.h
//  Ride
//
//  Created by Roberto Abreu on 16/11/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RAAlertConstant.h"

@interface RAAlertNotificationOption : NSObject

@property (nonatomic) RAAlertState state;
@property (nonatomic) NSString *categoryIdentifier;
@property (nonatomic) NSString *requestIdentifier;
@property (nonatomic) NSString *alertAction;
@property (nonatomic) NSDictionary *userInfo;

- (instancetype)initWithState:(RAAlertState)state withAlertActionTitle:(NSString*)alertAction categoryIdentifier:(NSString*)categoryIdentifier requestIdentifier:(NSString*)requestIdentifier andUserInfo:(NSDictionary*)userInfo;

//Convenience Initializers
+ (instancetype)notificationOptionWithState:(RAAlertState)state andAlertActionTitle:(NSString*)alertAction;
+ (instancetype)notificationOptionWithState:(RAAlertState)state andCategoryIdentifier:(NSString*)categoryIdentifier;
+ (instancetype)notificationOptionWithState:(RAAlertState)state andAlertActionTitle:(NSString *)alertAction userInfo:(NSDictionary *)userInfo;
+ (instancetype)notificationOptionWithState:(RAAlertState)state andCategoryIdentifier:(NSString *)categoryIdentifier userInfo:(NSDictionary *)userInfo;

@end
