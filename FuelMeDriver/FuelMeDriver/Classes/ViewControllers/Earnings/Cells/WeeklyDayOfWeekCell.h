//
//  WeeklyDayOfWeekCell.h
//  RideDriver
//
//  Created by Carlos Alcala on 7/25/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeekDayRides.h"

@interface WeeklyDayOfWeekCell : UITableViewCell

//IBOutlets
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *tripsLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalFareLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalRAFeeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalEarningsLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTipsLabel;

//Actions
- (void)configureCellWithWeekDay:(WeekDayRides*)weekday;

@end
