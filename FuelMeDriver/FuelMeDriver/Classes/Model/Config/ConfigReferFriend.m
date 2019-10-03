//
//  ConfigReferFriend.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 11/2/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "ConfigReferFriend.h"

@implementation ConfigReferFriend

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
              @"body"           : @"body",
              @"header"         : @"header",
              @"menuTitle"      : @"title",
              @"isSMSEnabled"   : @"smsEnabled",
              @"isEmailEnabled" : @"emailEnabled"
            };
}

- (BOOL)isEqual:(ConfigReferFriend *)object {
    if ([object isKindOfClass:[ConfigReferFriend class]]) {
        if (![self.header isEqualToString:object.header]) {
            return NO;
        }
        if (![self.menuTitle isEqualToString:object.menuTitle]) {
            return NO;
        }
        if (self.isSMSEnabled != object.isSMSEnabled) {
            return NO;
        }
        if (self.isEmailEnabled != object.isEmailEnabled) {
            return NO;
        }
        return YES;
    }
    return NO;
}

- (BOOL)enabled {
    return self.isSMSEnabled || self.isEmailEnabled;
}

@end
/***
referFriend =     {
    body = "Refer a driver, and you'll each receive a $125 bonus after your friend completes 20 trips with";
    emailEnabled = 1;
    header = "Receive a $125 bonus";
    smsEnabled = 1;
    title = "Refer a Friend";
}
*/
