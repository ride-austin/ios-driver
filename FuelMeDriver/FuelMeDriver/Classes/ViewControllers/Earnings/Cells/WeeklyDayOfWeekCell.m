//
//  WeeklyDayOfWeekCell.m
//  RideDriver
//
//  Created by Carlos Alcala on 7/25/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "WeeklyDayOfWeekCell.h"

#import "NSDate+Utils.h"
#import "NSNumber+Utils.h"
#import "NSString+Utils.h"

@implementation WeeklyDayOfWeekCell

- (void)configureCellWithWeekDay:(WeekDayRides*)weekday {
    //this is the only field always visible
    self.dateLabel.text = [weekday.date reportWeekDateString];
    
    self.tripsLabel.text = @"";
    self.totalTipsLabel.text = @"";
    self.totalFareLabel.text = @"";
    self.totalRAFeeLabel.text = @"";
    self.totalEarningsLabel.text = @"";
    
    if (weekday != nil) {
        self.tripsLabel.text         = [weekday.totalTrips trimZeros];
        self.totalTipsLabel.text     = [weekday.totalTips  currencyString];
        self.totalFareLabel.text     = [weekday.totalFare  currencyString];
        self.totalRAFeeLabel.text    = [weekday.totalRAFee currencyString];
        self.totalEarningsLabel.text = [weekday.totalEarnings currencyString];
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.dateLabel.text       = @"";
    self.tripsLabel.text      = @"";
    self.totalTipsLabel.text  = @"";
    self.totalFareLabel.text  = @"";
    self.totalRAFeeLabel.text = @"";
    self.totalEarningsLabel.text = @"";
}

@end
