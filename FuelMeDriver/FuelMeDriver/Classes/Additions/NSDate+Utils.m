//
//  NSDate+Utils.m
//  RideDriver
//
//  Created by Carlos Alcala on 7/20/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "NSDate+Utils.h"

#import "RADateManager.h"

@implementation NSDate (Utils)

+ (instancetype)trueDate {
#ifdef AUTOMATION
    return [NSDate date];
#else
    return [[RADateManager sharedInstance] currentDate];
#endif
}

- (NSString *)ISO8601StringFromDate{
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    [dateFormatter setAMSymbol:@""];
    [dateFormatter setPMSymbol:@""];
    NSString *iso8601String = [dateFormatter stringFromDate:self];

    //to follow ISO8601 format for server
    return [iso8601String stringByAppendingString:@"Z"];
}

- (NSDate *)midnight{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents * comp = [cal components:( NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute| NSCalendarUnitSecond) fromDate:self];
    
    [comp setHour:23];
    [comp setMinute:59];
    [comp setSecond:59];
    
    NSDate *midnight = [cal dateFromComponents:comp];
    
    return midnight;
}

- (NSDate *)zeroTime{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents * comp = [cal components:( NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:self];
    
    [comp setHour:0];
    [comp setMinute:0];
    [comp setSecond:0];
    
    NSDate *midnight = [cal dateFromComponents:comp];
    
    return midnight;
}

- (NSString *)convertToStringUsingFormat:(NSString *)format {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    dateFormatter.dateFormat = format;
    NSString *string = [dateFormatter stringFromDate:self];
    return string;
}

- (NSString *)reportTimeString {
    return [self convertToStringUsingFormat:@"hh:mm a"];
}

- (NSString *)reportHeaderString{
    return [self convertToStringUsingFormat:@"EEE, MMM dd"];
}

- (NSString *)reportWeekDateString{
    return [self convertToStringUsingFormat:@"MMM dd"];
}

- (NSDate *)firstWeekDayOfWeek:(NSDate *)date {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:2]; //For RideAusting weekly earnigns must to start in Monday.

    [calendar setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
    
    NSDateComponents *componentsCurrentDate = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday|NSCalendarUnitWeekOfMonth fromDate:date];
    
    NSDateComponents *componentsNewDate = [NSDateComponents new];
    
    componentsNewDate.year = componentsCurrentDate.year;
    componentsNewDate.month = componentsCurrentDate.month;
    componentsNewDate.weekOfMonth = componentsCurrentDate.weekOfMonth;
    componentsNewDate.weekday = calendar.firstWeekday;
    
    return [calendar dateFromComponents:componentsNewDate];
}

-(NSArray*)weekDates {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *beginningOfThisWeek = [self firstWeekDayOfWeek:self];
    
    NSMutableArray *dates = [NSMutableArray new];
    NSDateComponents *comps = [calendar components:NSUIntegerMax fromDate:beginningOfThisWeek];
    
    for (NSUInteger i = 0; i < 7; ++i) {
        [dates addObject:[calendar dateFromComponents:comps]];
        ++comps.day;
    }
    
    return dates;
}

+ (NSArray *)currentWeek {
    return [[NSDate trueDate] weekDates];
}

- (BOOL)equalToDate:(NSDate*)date {
    
    BOOL equal = NO;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger comps = (NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear);
    
    NSDateComponents *date1Components = [calendar components:comps
                                                    fromDate: self];
    NSDateComponents *date2Components = [calendar components:comps
                                                    fromDate: date];
    
    NSDate *date1 = [calendar dateFromComponents:date1Components];
    NSDate *date2 = [calendar dateFromComponents:date2Components];
    
    NSComparisonResult result = [date1 compare:date2];
    if (result == NSOrderedSame) {
        equal = YES;
    }
    
    return equal;
}

-(NSString *)monthName{
    NSDateFormatter *df = [NSDateFormatter new];
    df.dateFormat = @"MMMM";
    return [df stringFromDate:self];
}

- (NSString*)publicationFormat {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMM dd, yyyy";
    formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    return [formatter stringFromDate:self].uppercaseString;
}

@end
