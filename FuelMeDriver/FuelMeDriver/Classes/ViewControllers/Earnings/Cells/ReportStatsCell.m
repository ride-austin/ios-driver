//
//  ReportStatsCell.m
//  RideDriver
//
//  Created by Carlos Alcala on 7/18/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "ReportStatsCell.h"
#import "NSNumber+Utils.h"

@implementation ReportStatsCell

- (void)configureCellWithRating:(NSNumber*)rating andTrips:(NSNumber*)trips andOnline:(NSNumber*)seconds {
    [self.ratingButton setTitle:[rating trimZeros] forState:UIControlStateNormal];
    self.tripsLabel.text = [trips trimZeros];
    self.hoursLabel.text = [seconds timeFormat];
}

@end
