//
//  DatePickerModel.m
//  Ride
//
//  Created by Theodore Gonzalez on 5/24/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "DatePickerModel.h"

@interface DatePickerModel()
@property (nonatomic, readwrite) UIDatePickerMode datePickerMode;
@end

@implementation DatePickerModel
-(instancetype)initWithDatePickerMode:(UIDatePickerMode)datePickerMode fromTodayUntil:(NSDate *)futureValidDate {
    if (self = [super init]) {
        _datePickerMode = datePickerMode;
        _minimumDate = [NSDate date];
        _maximumDate = futureValidDate;
        _defaultDate = self.minimumDate;
    }
    return self;
}
-(instancetype)initWithDatePickerMode:(UIDatePickerMode)datePickerMode fromPastDate:(NSDate *)pastValidDate {
    if (self = [super init]) {
        _datePickerMode = datePickerMode;
        _minimumDate = pastValidDate;
        _maximumDate = [NSDate date];
        _defaultDate = self.maximumDate;
    }
    return self;
}

+(instancetype)datePickerMode:(UIDatePickerMode)datePickerMode fromTodayUntil:(NSDate *)futureValidDate {
    return [[self alloc] initWithDatePickerMode:datePickerMode fromTodayUntil:futureValidDate];
}
+(instancetype)datePickerMode:(UIDatePickerMode)datePickerMode fromPastDate:(NSDate *)pastValidDate {
    return [[self alloc] initWithDatePickerMode:datePickerMode fromPastDate:pastValidDate];
}
#pragma mark - Nonnull properties
-(NSDate *)minimumDate {
    return _minimumDate ?: [NSDate date];
}
-(NSDate *)maximumDate {
    return _maximumDate ?: [NSDate date];
}
-(NSDate *)defaultDate {
    return _defaultDate ?: [NSDate date];
}
-(NSDateFormatter *)dateFormatter {
    if (_dateFormatter == nil) {
        _dateFormatter = [NSDateFormatter new];
        _dateFormatter.timeStyle = NSDateFormatterNoStyle;
        _dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    }
    return _dateFormatter;
}
@end
