//
//  WeeklyChartCell.h
//  RideDriver
//
//  Created by Carlos Alcala on 7/25/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeekDayRides.h"
#import "TWRChart.h"

@interface WeeklyChartCell : UITableViewCell

@property (weak, nonatomic) IBOutlet TWRChartView *chartView;

//Properties
@property (strong, nonatomic) NSArray *weekDays;

//Actions
- (void)configureCellWithWeekDaysData:(NSArray*)weekdays;


@end
