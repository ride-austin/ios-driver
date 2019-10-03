//
//  NSString+DeviceToken.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 12/9/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "NSString+DeviceToken.h"

@implementation NSString (DeviceToken)
+ (NSString *)convertDeviceTokenToString:(id)deviceToken {
    if ([deviceToken isKindOfClass:[NSString class]]) {
        return deviceToken;
    } else {
        NSMutableString *hexString = [NSMutableString string];
        const unsigned char *bytes = [deviceToken bytes];
        for (int i = 0; i < [deviceToken length]; i++) {
            [hexString appendFormat:@"%02x", bytes[i]];
        }
        return [NSString stringWithString:hexString];
    }
}
@end
