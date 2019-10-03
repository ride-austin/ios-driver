//
//  WeeklyChartCell.m
//  RideDriver
//
//  Created by Carlos Alcala on 7/25/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "WeeklyChartCell.h"

#import "UIColor+HexUtils.h"

@implementation WeeklyChartCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.chartView.backgroundColor = [UIColor clearColor];
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    self.chartView.frame = CGRectMake(0, 0, screenWidth, 300);
}

- (void)configureCellWithWeekDaysData:(NSArray*)weekdays {
    
    self.weekDays = weekdays;
    
    NSMutableArray* dataPoints = [NSMutableArray new];
    for (WeekDayRides *weekday in self.weekDays) {
        [dataPoints addObject:weekday.totalEarnings];
    }
    
    // Build chart data
    TWRDataSet *dataSet1 = [[TWRDataSet alloc] initWithDataPoints:dataPoints
                                                        fillColor:[[UIColor colorWithHex:@"#45AC1D"] colorWithAlphaComponent:0.5]
                                                      strokeColor:[UIColor colorWithHex:@"#45AC1D"]];
    
    NSArray *labels = @[@"M", @"T", @"W", @"T", @"F", @"S", @"S"];
    TWRBarChart *bar = [[TWRBarChart alloc] initWithLabels:labels
                                                  dataSets:@[dataSet1]
                                                  animated:YES];
    // Load data
    [self.chartView loadBarChart:bar];
}

@end
