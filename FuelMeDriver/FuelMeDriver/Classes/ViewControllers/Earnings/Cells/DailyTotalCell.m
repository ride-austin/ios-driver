//
//  DailyTotalCell.m
//  RideDriver
//
//  Created by Carlos Alcala on 7/18/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "DailyTotalCell.h"

#import "NSDate+Utils.h"
#import "NSNumber+Utils.h"

@implementation DailyTotalCell

- (void)configureCellWithTotal:(NSNumber*)total andDate:(NSDate*)date {
    self.totalLabel.text = [total currencyString];
    self.dateLabel.text = [date reportHeaderString];
}

@end
