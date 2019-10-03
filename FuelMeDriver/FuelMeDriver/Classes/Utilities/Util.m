//
//  Util.m
//  RideDriver
//
//  Created by Roberto Abreu on 3/11/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "Util.h"

#import "ConfigurationManager.h"
#import "RAAlertManager.h"
@implementation Util

+ (UIImage *)imageFromString:(NSString *)string attributes:(NSDictionary *)attributes size:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [string drawInRect:CGRectMake(0, 0, size.width, size.height) withAttributes:attributes];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end

@implementation Util (Contact)

+ (NSString *)maskNumberIfNeeded:(NSString *)phoneNumber {
    BOOL hasDirectConnectEnabled = [ConfigurationManager shared].global.isPhoneMaskingEnabled && [ConfigurationManager shared].global.directConnectPhone;
    
    if (hasDirectConnectEnabled) {
        return [ConfigurationManager shared].global.directConnectPhone;
    }
    
    return phoneNumber;
}

+ (void)startContactCallWithPhoneNumber:(NSString *)contactNumber {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]]) {
        NSURL *callURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",contactNumber]];
        [[UIApplication sharedApplication] openURL:callURL];
    } else {
        [RAAlertManager showAlertWithTitle:@"CALL" message:contactNumber];
    }
}

+ (void)startContactSMSWithPhoneNumber:(NSString *)contactNumber {
    if ([MFMessageComposeViewController canSendText]) {
        NSURL *smsURL = [NSURL URLWithString:[NSString stringWithFormat:@"sms:%@", contactNumber]];
        [[UIApplication sharedApplication] openURL:smsURL];
    } else {
        [RAAlertManager showAlertWithTitle:@"SMS" message:contactNumber];
    }
}

@end
