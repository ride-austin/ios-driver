//
//  DailyEarningsViewController.h
//  RideDriver
//
//  Created by Carlos Alcala on 7/18/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "BaseViewController.h"
#import "WeekDayRides.h"

@interface DailyEarningsViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource>

//IBOutlets
@property (weak, nonatomic) IBOutlet UITableView *tableView;

//Properties
@property (strong, nonatomic) NSMutableArray *expandedCells;

@property (assign, nonatomic) CGFloat expandedCellHeight;
@property (assign, nonatomic) CGFloat expandedCellHeightCancelled;

@property (assign, nonatomic) CGFloat normalCellHeight;

@property (strong, nonatomic) NSNumber *total;
@property (strong, nonatomic) NSNumber *rating;
@property (strong, nonatomic) NSNumber *online;

@property (assign, nonatomic) BOOL shouldDisplayTable;

@property (strong, nonatomic) WeekDayRides *weekday;

@end
