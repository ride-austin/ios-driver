//
//  NSString+Utils.h
//  RideDriver
//
//  Created by Carlos Alcala on 8/31/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <SinchVerification/SinchVerification.h>

#import "RideDriverEnums.h"

@class QueueEvent;
@interface NSString (Utils)

+ (NSString*)addSuffixToNumber:(NSInteger) number;
+ (NSString*)getPhotoTypeStringWithCarPhotoType:(CarPhotoType)carPhotoType;
- (NSString*)validPhoneWithSINFormat:(SINPhoneNumberFormat)format;
- (NSString*)matchWithPattern:(NSString *)pattern;
+ (NSString*)queueUpdateMessageWithEvent:(QueueEvent *)queueEvent fromPositions:(NSDictionary *)response;
- (NSDate*)httpHeaderResponseDate;
- (NSString *)localized;

@end
