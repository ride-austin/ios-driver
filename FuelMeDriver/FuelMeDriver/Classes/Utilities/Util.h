//
//  Util.h
//  RideDriver
//
//  Created by Roberto Abreu on 3/11/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Util : NSObject

+ (UIImage *)imageFromString:(NSString *)string attributes:(NSDictionary *)attributes size:(CGSize)size;

@end

@interface Util (Contact)

+ (NSString *)maskNumberIfNeeded:(NSString*)phoneNumber;
+ (void)startContactCallWithPhoneNumber:(NSString*)phoneNumber;
+ (void)startContactSMSWithPhoneNumber:(NSString*)phoneNumber;

@end
