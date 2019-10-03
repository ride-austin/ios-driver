//
//  WeeklyTotalCell.m
//  RideDriver
//
//  Created by Carlos Alcala on 7/25/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "WeeklyTotalCell.h"

#import "NSNumber+Utils.h"

@implementation WeeklyTotalCell

- (void) configureCellWithTotal:(NSNumber *)total {
    self.totalLabel.text = [total currencyString];
}

@end
