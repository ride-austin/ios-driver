//
//  DailyEarningsViewController.m
//  RideDriver
//
//  Created by Carlos Alcala on 7/18/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "DailyEarningsViewController.h"

#import "DailyBasicCell.h"
#import "DailyCancelledRideCell.h"
#import "DailyTotalCell.h"
#import "NSDate+Utils.h"
#import "RADriversAPI.h"
#import "ReportStatsCell.h"
#import "SupportTableViewController.h"
#import "SupportTopicAPI.h"
#import "NSString+Utils.h"
#import "RAAlertManager.h"

//Daily Sections Enum
typedef enum : NSUInteger {
    DailySectionTotal = 0,
    DailySectionTrips,
    DailySectionCount
} DailySection;

//Daily Row Type Enum
typedef enum : NSUInteger {
    DailyRowTotal = 0,
    DailyRowStats,
    DailyRowTrip
} DailyRowType;

@interface DailyEarningsViewController () <DailyEarningsCellDelegate>

@end

@implementation DailyEarningsViewController

- (void)setOnline:(NSNumber *)online {
    _online = online;
    [self reloadReportStatsCell];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = [@"Daily Earnings" localized];

    //setup table View
    [self configureTableView];
    
    //setup UI
    [self configureUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //FIX: to avoid display the header view for gropued tableView
    CGRect frame = self.tableView.tableHeaderView.frame;
    frame.size.height = 1;
    UIView *headerView = [[UIView alloc] initWithFrame:frame];
    [self.tableView setTableHeaderView:headerView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //API get driver rides
    [self showHUD];
    
    //load data after delay to avoid freeze UI on transition
    if ([self respondsToSelector:@selector(loadData)]) {
        [self performSelector:@selector(loadData) withObject:self afterDelay:0.8];
    }
}

- (void)configureTableView {
    
    self.shouldDisplayTable = NO;
    self.expandedCells = [NSMutableArray new];
    
    self.expandedCellHeightCancelled = 380;
    self.expandedCellHeight          = 756;
    self.normalCellHeight            = 60;
    
    self.total = [NSNumber numberWithDouble:0];
    
    //register NIBs
    NSArray *nibNames = @[@"DailyTotalCell",@"ReportStatsCell",@"DailyBasicCell",@"DailyCancelledRideCell"];
    
    for (NSString *nibName in nibNames) {
        [self.tableView registerNib:[UINib nibWithNibName:nibName bundle:nil]
             forCellReuseIdentifier:nibName];
    }
}

- (void)configureUI {
    //setup the UI default colors
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.tableView setBackgroundColor:[UIColor colorWithRed:245.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setAllowsSelection:NO];
}

- (void)loadData {
    //today fixed zero time
    NSDate *today = [self.weekday.date zeroTime];
    
    //today midnight
    NSDate *midnight = [self.weekday.date midnight];
    
    //ISO-8601 Date Format
    NSString *todayString = [today ISO8601StringFromDate];
    NSString *midnightString = [midnight ISO8601StringFromDate];
    
    //API params for today (daily) earnings
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    //calculate rides total
    self.total = [self calculateTripsTotal];
    
    //very important here before load table
    self.shouldDisplayTable = YES;
    
    //IMPORTANT: load table with static data before load online API to avoid crash
    [self.tableView reloadData];
    
    params[@"from"] = todayString;
    params[@"to"] = midnightString;
    
    __weak DailyEarningsViewController *weakSelf = self;
    
    //RA1374: Only online hours API, the rating, trips are comming from Weekly Report
    NSNumber *driverID = [RASessionManager shared].currentSession.driver.modelID;
    [RADriversAPI getOnlineTimeForDriver:driverID withParams:params andCompletion:^(NSDictionary *result, NSError *error) {
        [weakSelf hideHUD];
        if (error) {
            //RA-1489 - Fixed just send the error object
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive]];
        } else {
            //check content
            if ([result objectForKey:@"seconds"] != nil) {
                double seconds = [[result valueForKey:@"seconds"] doubleValue];
                
                self.online = [NSNumber numberWithDouble:seconds];
            }
        }
    }];
}

/**
 *  reload the row with current rating, trips, hours online
 */
- (void)reloadReportStatsCell {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationNone];
}

- (NSNumber*)calculateTripsTotal {
    double total = 0;
    for (RideFareDataModel *ride in self.weekday.rides) {
        total += [ride.driverPayment doubleValue];
    }
    
    return [NSNumber numberWithDouble:total];
}

#pragma mark - Actions

- (IBAction)closeAction:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return DailySectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.shouldDisplayTable) {
        switch (section) {
            case DailySectionTotal:
                return 2;
            case DailySectionTrips:
                return self.weekday.rides.count;
        }
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak DailyEarningsViewController *weakSelf = self;
    switch (indexPath.section) {
        case DailySectionTotal: {
            switch (indexPath.row) {
                case DailyRowTotal: {
                    DailyTotalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DailyTotalCell" forIndexPath:indexPath];
                    [cell configureCellWithTotal:self.total andDate:self.weekday.date];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    return cell;
                
                }
                case DailyRowStats: {
                    ReportStatsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReportStatsCell" forIndexPath:indexPath];
                    // Stats* stats = [self statsForDate:today];
                    [cell configureCellWithRating:[NSNumber numberWithDouble:[self.rating doubleValue]] andTrips:[NSNumber numberWithInt:(int)self.weekday.rides.count] andOnline:[NSNumber numberWithDouble:[self.online doubleValue]]];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    return cell;
                }
            }
        }
        case DailySectionTrips: {
            RideFareDataModel* ride = [self.weekday.rides objectAtIndex:indexPath.row];

            if (ride.isRideCancelled) {
                DailyCancelledRideCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DailyCancelledRideCell" forIndexPath:indexPath];
                
                [cell configureCellWithRide:ride];
                
                //only show topLine on first row
                cell.topLine.hidden = indexPath.row == 0 ? NO : YES;
                
                cell.delegate = self;
                
                __weak DailyCancelledRideCell *weakCell = cell;
                cell.expandBlock = ^{
                    [weakSelf didToggleAtIndexPath:indexPath];
                    [weakCell toggleExpand:[weakSelf.expandedCells containsObject:indexPath]];
                };
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                return cell;

            } else {
                DailyBasicCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DailyBasicCell" forIndexPath:indexPath];
                
                [cell configureCellWithRide:ride];
                
                //only show topLine on first row
                cell.topLine.hidden = indexPath.row == 0 ? NO : YES;
                cell.RAFeeTitle.text = [NSString stringWithFormat:[@"%@ Fee" localized],[[ConfigurationManager appName] stringByReplacingOccurrencesOfString:@" " withString:@""]];
                cell.delegate = self;
                
                __weak DailyBasicCell *weakCell = cell;
                cell.expandBlock = ^{
                    [weakSelf didToggleAtIndexPath:indexPath];
                    [weakCell toggleExpand:[weakSelf.expandedCells containsObject:indexPath]];
                };
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                return cell;
            }
        }
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == DailySectionTrips && self.shouldDisplayTable) {
        UIView *sectionHeaderView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, tableView.frame.size.width, 50.0)];
        sectionHeaderView.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0];
        
        UILabel *headerLabel = [[UILabel alloc] initWithFrame: CGRectMake(15, 0, 100, 50)];
        
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.textAlignment = NSTextAlignmentLeft;
        [headerLabel setFont:[UIFont fontWithName:@"Montserrat-Light" size:15]];
        headerLabel.textColor = [UIColor blackColor];
        headerLabel.text = [@"Trips" localized];
        [sectionHeaderView addSubview:headerLabel];
        
        return sectionHeaderView;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case DailySectionTotal:
            break;
        case DailySectionTrips:{
            break;
        }
    }
}

- (void)didToggleAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.expandedCells containsObject:indexPath]) {
        [self.expandedCells removeAllObjects];
    } else {
        [self.expandedCells removeAllObjects];
        [self.expandedCells addObject:indexPath];
    }
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    UITableViewCell * cell = (UITableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [self.tableView setContentOffset:CGPointMake(0, cell.frame.origin.y) animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case DailySectionTotal:{
            switch (indexPath.row) {
                case DailyRowTotal:
                    return 125;
                case DailyRowStats:
                    return 80;
            }
        }
        case DailySectionTrips:{
            if ([self.expandedCells containsObject:indexPath]) {
            
                RideFareDataModel* ride = [self.weekday.rides objectAtIndex:indexPath.row];
            
                if (ride.isRideCancelled) {
                    CGFloat dxHeight = (ride.end.fullAddress == nil) ? 65.0 : 0.0;
                    return self.expandedCellHeightCancelled - dxHeight;
                }else{
                    return self.expandedCellHeight;
                }
                
            } else {
                return self.normalCellHeight;
            }
        }
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == DailySectionTotal) {
        return 1;
    }
    
    if (section == DailySectionTrips) {
        return 50;
    }
    
    return 0;
}

#pragma - Daily Earnings Delegate

- (void)sendEmailWithRide:(RideFareDataModel *)ride {
    [self showHUD];
    [SupportTopicAPI getSupportTopicListWithCompletion:^(NSArray<RASupportTopic *> *supportTopics, NSError *error) {
        [self hideHUD];
        if (!error) {
            SupportTableViewController *supportTableViewController = (SupportTableViewController*)[self createViewControllerFromStoryboard:@"SupportTopics" withIdentifier:@"SupportTableViewController"];
            supportTableViewController.subTopics = supportTopics;
            supportTableViewController.rideId = ride.modelID;
            [self.navigationController pushViewController:supportTableViewController animated:YES];
        } else {
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive]];
        }
    }];
}

@end
