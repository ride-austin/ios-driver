//
//  RAAlertNotificationOption.m
//  Ride
//
//  Created by Roberto Abreu on 16/11/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RAAlertNotificationOption.h"

@implementation RAAlertNotificationOption

- (instancetype)initWithState:(RAAlertState)state withAlertActionTitle:(NSString *)alertAction categoryIdentifier:(NSString *)categoryIdentifier requestIdentifier:(NSString *)requestIdentifier andUserInfo:(NSDictionary *)userInfo {
    if (self = [super init]) {
        self.state = state;
        self.alertAction = alertAction;
        self.categoryIdentifier = categoryIdentifier;
        self.requestIdentifier = requestIdentifier;
        self.userInfo = userInfo;
    }
    return self;
}

+ (instancetype)notificationOptionWithState:(RAAlertState)state andAlertActionTitle:(NSString *)alertAction {
    return [[RAAlertNotificationOption alloc] initWithState:state withAlertActionTitle:alertAction categoryIdentifier:nil requestIdentifier:nil andUserInfo:nil];
}

+ (instancetype)notificationOptionWithState:(RAAlertState)state andCategoryIdentifier:(NSString *)categoryIdentifier {
    return [[RAAlertNotificationOption alloc] initWithState:state withAlertActionTitle:nil categoryIdentifier:categoryIdentifier requestIdentifier:nil andUserInfo:nil];
}

+ (instancetype)notificationOptionWithState:(RAAlertState)state andAlertActionTitle:(NSString *)alertAction userInfo:(NSDictionary *)userInfo {
    return [[RAAlertNotificationOption alloc] initWithState:state withAlertActionTitle:alertAction categoryIdentifier:nil requestIdentifier:nil andUserInfo:userInfo];
}

+ (instancetype)notificationOptionWithState:(RAAlertState)state andCategoryIdentifier:(NSString *)categoryIdentifier userInfo:(NSDictionary *)userInfo {
    return [[RAAlertNotificationOption alloc] initWithState:state withAlertActionTitle:nil categoryIdentifier:categoryIdentifier requestIdentifier:nil andUserInfo:userInfo];
}

@end
