//
//  DatePickerModel.h
//  Ride
//
//  Created by Theodore Gonzalez on 5/24/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DatePickerModel : NSObject
@property (nonatomic, readonly) UIDatePickerMode datePickerMode;
@property (nonatomic) NSDate * _Nonnull defaultDate;
@property (nonatomic) NSDate * _Nonnull minimumDate;
@property (nonatomic) NSDate * _Nonnull maximumDate;
@property (nonatomic) NSDateFormatter * _Nonnull dateFormatter;
@property (nonatomic) NSNumber * _Nullable datePickerMinuteInterval;
+(instancetype _Nonnull )datePickerMode:(UIDatePickerMode)datePickerMode fromTodayUntil:(NSDate * _Nonnull)futureValidDate;
+(instancetype _Nonnull )datePickerMode:(UIDatePickerMode)datePickerMode fromPastDate:(NSDate * _Nonnull)pastValidDate;
@end
