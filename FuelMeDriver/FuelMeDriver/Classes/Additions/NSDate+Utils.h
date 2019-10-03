//
//  NSDate+Utils.h
//  RideDriver
//
//  Created by Carlos Alcala on 7/20/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Utils)

+ (instancetype)trueDate;
- (NSString *)ISO8601StringFromDate;
- (NSDate *)midnight;
- (NSDate *)zeroTime;
- (NSString *)convertToStringUsingFormat:(NSString *)format;
- (NSString *)reportHeaderString;
- (NSString *)reportTimeString;
- (NSString *)reportWeekDateString;
- (NSDate *)firstWeekDayOfWeek:(NSDate *)date;
- (NSArray *)weekDates;
- (BOOL)equalToDate:(NSDate*)date;
- (NSString*)monthName;
+ (NSArray *)currentWeek;
- (NSString*)publicationFormat;

@end
