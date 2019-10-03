//
//  NSString+DeviceToken.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 12/9/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (DeviceToken)
+ (NSString *)convertDeviceTokenToString:(id)deviceToken;
@end
