//
//  WeeklyEarningsViewController.m
//  RideDriver
//
//  Created by Carlos Alcala on 7/18/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "WeeklyEarningsViewController.h"

#import "DailyEarningsViewController.h"
#import "NSDate+Utils.h"
#import "NSObject+className.h"
#import "RADriversAPI.h"
#import "ReportStatsCell.h"
#import "RideDriverConstants.h"
#import "UIColor+HexUtils.h"
#import "WeeklyChartCell.h"
#import "WeeklyDayOfWeekCell.h"
#import "WeeklyTotalCell.h"
#import "WeeklyTripHeaderCell.h"
#import "NSString+Utils.h"
#import "RAAlertManager.h"

#define kDefaultDay 1
#define kMonthLaunch 6
#define kYearLaunch 2016

typedef enum : NSUInteger {
    WeeklySectionTotal = 0,
    WeeklySectionTrips,
    WeeklySectionCount
} WeeklySection;

typedef enum : NSUInteger {
    WeeklyRowChart = 0,
    WeeklyRowStats,
    WeeklyRowWeekTotal
} WeeklyRowType;

typedef enum : NSUInteger {
    WeeklyRowTripHeader = 0,
    WeeklyRowDayOfWeek
} WeeklyRowTypeTrip;

@interface WeeklyEarningsViewController ()

@end

@implementation WeeklyEarningsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [@"Weekly Earnings" localized];
    [self configureUI];
    [self configureData];
    [self loadData];
    [self addObservers];
}

- (void)addObservers {
    __weak WeeklyEarningsViewController *weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:kNetworkReachabilityStatusChanged object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull notification) {
        
        NSNumber *statusNumber = (NSNumber *)notification.object;
        AFRKNetworkReachabilityStatus status = [statusNumber intValue];
        
        switch (status) {
            case AFRKNetworkReachabilityStatusReachableViaWiFi:
            case AFRKNetworkReachabilityStatusReachableViaWWAN:
                [weakSelf loadData];
                break;
            default:
                break;
        }
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //FIX: to avoid display the header view for grouped tableView
    CGRect frame = self.tableView.tableHeaderView.frame;
    frame.size.height = 1;
    UIView *headerView = [[UIView alloc] initWithFrame:frame];
    [self.tableView setTableHeaderView:headerView];
    
    //update scroll layout
    self.scrollView.frame = self.view.bounds;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self hideHUD];
}

- (UIUserInterfaceStyle)overrideUserInterfaceStyle {
    return UIUserInterfaceStyleLight;
}

- (void)configureData {
    self.weekDates = [NSMutableArray new];
    self.weekDaysData = [NSMutableArray new];    
    
    self.total = [NSNumber numberWithDouble:0];
    self.online = [NSNumber numberWithDouble:0];
    self.rating = [NSNumber numberWithDouble:0];
    
    self.expandedCalendarHeight = 300;
    
    self.currentDate = [NSDate trueDate];
    self.startOfWeek = [NSDate trueDate];
    self.currentWeek = [NSDate currentWeek];
    
    //default default week dates
    [self setupWeekForDate:self.currentDate];
    
    [self setupCalendar];
}

- (void)configureTableView {
    //register NIBs
    NSArray *nibNames = @[@"WeeklyChartCell",@"ReportStatsCell", @"WeeklyTotalCell",@"WeeklyTripHeaderCell",@"WeeklyDayOfWeekCell"];
    for (NSString *nibName in nibNames) {
        [self.tableView registerNib:[UINib nibWithNibName:nibName bundle:nil]
             forCellReuseIdentifier:nibName];
    }
}

- (void)configureUI {
    //default background
    [self.view setBackgroundColor:[UIColor whiteColor]];

    //configure calendar
    [self configureCalendar];
    
    //configure table
    [self.tableView setBackgroundColor:[UIColor colorWithRed:245.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setAllowsSelection:YES];
    
    //setup table View
    [self configureTableView];
}

- (void)loadData {
    //week start
    NSString *startDateString = [[[self.weekDates objectAtIndex:0] zeroTime] ISO8601StringFromDate];
    NSString *endDateString = [[[self.weekDates objectAtIndex:6] midnight] ISO8601StringFromDate];
    
    //API params for today (Weekly) earnings
    NSDictionary * params = @{ @"completedOnAfter"  : startDateString,
                               @"completedOnBefore" : endDateString };
    
    RADriverDataModel *driver = [RASessionManager shared].currentSession.driver;
    __weak WeeklyEarningsViewController *weakSelf = self;
    
    self.rides = [NSMutableArray new];
    [self showHUD];
    [RADriversAPI getRideFaresForDriverWithId:driver.modelID withParams:params andCompletion:^(NSDictionary *result, NSError *error) {
        [weakSelf hideHUD];
        if (error) {
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive andShownOption:AllowNetworkError]];
        } else {
            
            //check content
            if ([result objectForKey:@"content"] != nil) {
                NSArray* content = [result objectForKey:@"content"];
                
                if ([content count] > 0) {
                    [self.rides removeAllObjects];
                    
                    NSArray *ridesResponse = [MTLJSONAdapter modelsOfClass:[RideFareDataModel class] fromJSONArray:content error:nil];

                    for (RideFareDataModel *rideFare in ridesResponse) {
                        if (rideFare.shouldShowInEarnings) {
                            [self.rides addObject:rideFare];
                        }
                    }
                }
                
                //generate weekly data (even empty to display the daily report cells with empty data)
                [self generateWeeklyData];
                
                //reload table after get data
                [self.tableView reloadData];
                [self updateScrollView];
            }
        }
    }];
    
    //retrieve Driver overall rating
    self.rating = driver.rating;
    
    //API get driver online hours
    NSDictionary *onlineParams = @{@"from": startDateString,
                                   @"to"  : endDateString};
    [RADriversAPI getOnlineTimeForDriver:driver.modelID withParams:onlineParams andCompletion:^(NSDictionary *result, NSError *error) {
        if (error) {
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive]];
        } else {
            if ([result objectForKey:@"seconds"] != nil) {
                double seconds = [[result valueForKey:@"seconds"] doubleValue];
                self.online = [NSNumber numberWithDouble:seconds];
                [self reloadStatsRow];
            }
        }
    }];
}

- (void)reloadStatsRow {
    if ([self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:WeeklyRowStats inSection:WeeklySectionTotal]]) {
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:WeeklyRowStats inSection:WeeklySectionTotal]] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)reloadHeaderSection {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:WeeklySectionTotal];
    NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}

- (void)setupWeekForDate:(NSDate*)date {
    [self.weekDates removeAllObjects];
    self.weekDates = [NSMutableArray arrayWithArray:[date weekDates]];
    [self updateCalendar];
}

- (void)generateWeeklyData {
    [self.weekDaysData removeAllObjects];
    double totalDriverPayment = 0;
    
    for (NSDate *weekDate in self.weekDates) {
        NSMutableArray<RideFareDataModel *> *weekDateRides = [NSMutableArray new];
        
        if (self.rides.count > 0) {
            for (RideFareDataModel *ride in self.rides) {
                if ([weekDate equalToDate:ride.dateToConsider]) {
                    [weekDateRides addObject:ride];
                    totalDriverPayment += ride.driverPayment.doubleValue;
                }
            }
        }
        
        [weekDateRides sortUsingComparator:^NSComparisonResult(RideFareDataModel *_Nonnull obj1, RideFareDataModel *_Nonnull obj2) {
            return [[obj1 dateToConsider] compare:obj2.dateToConsider];
        }];
        
        WeekDayRides *weekday = [[WeekDayRides alloc] initWithDate:weekDate andRides:weekDateRides];
        [self.weekDaysData addObject:weekday];
        self.total = [NSNumber numberWithDouble:totalDriverPayment];
    }
}

#pragma mark - Actions

- (IBAction)closeAction:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return WeeklySectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.weekDaysData.count > 0) {
        switch (section) {
            case WeeklySectionTotal:
                return 3;
            case WeeklySectionTrips:
                return 7 + 1; //7 days + header
        }
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.weekDaysData.count > 0) {
        switch (indexPath.section) {
            case WeeklySectionTotal:{
                switch (indexPath.row) {
                    case WeeklyRowChart:{
                        WeeklyChartCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WeeklyChartCell" forIndexPath:indexPath];
                        
                        [cell configureCellWithWeekDaysData:self.weekDaysData];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        return cell;
                    }
                    case WeeklyRowStats:{
                        ReportStatsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReportStatsCell" forIndexPath:indexPath];
                        [cell configureCellWithRating:[NSNumber numberWithDouble:[self.rating doubleValue]] andTrips:[NSNumber numberWithInt:(int)self.rides.count] andOnline:[NSNumber numberWithDouble:[self.online doubleValue]]];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        return cell;
                    }
                    case WeeklyRowWeekTotal:{
                        WeeklyTotalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WeeklyTotalCell" forIndexPath:indexPath];
                        [cell configureCellWithTotal:self.total];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        return cell;
                    }
                }
            }
            case WeeklySectionTrips:{
                
                if (indexPath.row == WeeklyRowTripHeader) {
                    WeeklyTripHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WeeklyTripHeaderCell" forIndexPath:indexPath];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    return cell;
                } else {
                    WeeklyDayOfWeekCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WeeklyDayOfWeekCell" forIndexPath:indexPath];
                    
                    WeekDayRides *weekday = nil;
                    if (self.weekDaysData.count > 0) {
                        weekday = [self.weekDaysData objectAtIndex:indexPath.row - 1];
                    }
                    
                    [cell configureCellWithWeekDay:weekday];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    return cell;
                }
            }
        }
            
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == WeeklySectionTrips && indexPath.row != WeeklyRowTripHeader) {
        WeekDayRides *weekday = [self.weekDaysData objectAtIndex:indexPath.row - 1];
        if (weekday.rides.count > 0) {
            DailyEarningsViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:[DailyEarningsViewController className]];
            vc.weekday = weekday;
            vc.rating = self.rating;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == WeeklySectionTrips) {
        UIView *sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30.0)];
        sectionHeaderView.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0];
        return sectionHeaderView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case WeeklySectionTotal:{
            switch (indexPath.row) {
                case WeeklyRowChart:
                    return 300;
                case WeeklyRowStats:
                    return 80;
                case WeeklyRowWeekTotal:
                    return 80;
            }
        }
        case WeeklySectionTrips:{
            switch (indexPath.row) {
                case WeeklyRowTripHeader:{
                    return 70;
                }
                default: {
                    return 55;
                }
            }
        }
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == WeeklySectionTotal){
        return 1;
    }
    
    if (section == WeeklySectionTrips) {
        return 30;
    }
    
    return 0;
}

- (void)toggleCalendar {
    CGFloat height = 0;
    CGFloat labelHeight = 0;
    CGFloat alpha = 0;
    if (self.calendarHeightConstraint.constant != self.expandedCalendarHeight) {
        height = self.expandedCalendarHeight;
        labelHeight = 30;
        alpha = 1.0;
    }
    
    self.calendarHeightConstraint.constant = height;
    self.monthLabelHeightConstraint.constant = labelHeight;
    [UIView animateWithDuration:0.5 delay:0.01 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.calendarContainerView.alpha = alpha;
        self.monthLabel.alpha = alpha;
        [self.view layoutIfNeeded];
    } completion:^(BOOL done){
        [self updateScrollView];
        [self.calendarManager reload];
    }];
}

- (void)updateScrollView {
     CGRect contentRect = CGRectZero;
     for (UIView *view in self.scrollView.subviews) {
         contentRect = CGRectUnion(contentRect, view.frame);
     }
     self.scrollView.contentSize = contentRect.size;
}

- (void)reset {
    self.total = [NSNumber numberWithDouble:0];
    self.online = [NSNumber numberWithDouble:0];

    [self.weekDaysData removeAllObjects];
    [self.rides removeAllObjects];
    
    [self.tableView reloadData];
}

- (void)reloadByDate:(NSDate*)date {
    //only if the date is from another week
    if (![self.weekDates containsObject:date]) {
        
        //reset the tableView and totals to avoid displaying cache data on empty weeks
        [self reset];
        
        self.currentDate = date;
        
        [self setupWeekForDate:self.currentDate];
        [self loadData];
        
        [self.calendarManager reload];
        
        if(![self.calendarManager.dateHelper date:self.calendarView.date isTheSameMonthThan:date]){
            if([self.calendarView.date compare:date] == NSOrderedAscending){
                [self.calendarView loadNextPageWithAnimation];
            }
            else{
                [self.calendarView loadPreviousPageWithAnimation];
            }
        }
    }
}

#pragma mark - Weekly Calendar Delegate

- (void)selectedDate:(NSDate*)date {
    [self reloadByDate:date];
}

- (void)previousWeek:(NSDate *)date {
    [self reloadByDate:date];
}

- (void)nextWeek:(NSDate *)date {
    [self reloadByDate:date];
}


#pragma mark - Calendar Helper Functions

- (void)configureCalendar {
    self.calendarManager = [JTCalendarManager new];
    self.calendarManager.delegate = self;
    
    self.calendarManager.settings.weekDayFormat = JTCalendarWeekDayFormatSingle;
    self.calendarManager.settings.firstDayOfWeek = JTCalendarFirstDayOfWeekMonday;
}

- (void)setupCalendar {
    [self.calendarManager setContentView:self.calendarView];
    [self.calendarManager setDate:self.startOfWeek];
    
    self.monthLabel.text = [self.calendarManager.date monthName];

    // setup limits
    [self createMinAndMaxDate];
    
    //update calendar based on current dates
    [self updateWeeklyNav];
}

- (void)updateCalendar {
    //setup calender with current week start/end dates
    self.dateSelected = [self.weekDates firstObject];
    self.startOfWeek = [self.weekDates firstObject];
    self.endOfWeek = [self.weekDates lastObject];
    
    self.weekLabel.text = [NSString stringWithFormat:@"%@ - %@, %@", [self.startOfWeek reportWeekDateString], [self.endOfWeek reportWeekDateString], [self.endOfWeek convertToStringUsingFormat:@"yyyy"]];
    
    self.monthLabel.text = [self.calendarManager.date monthName];

    [self updateWeeklyNav];
}

- (void)updateWeeklyNav {
    if ([self.currentWeek containsObject:[self.weekDates firstObject]]) {
        self.nextWeekButton.enabled = false;
        self.nextWeekIcon.image = [UIImage imageNamed:@"right-arrow"];
    } else {
        self.nextWeekButton.enabled = true;
        self.nextWeekIcon.image = [UIImage imageNamed:@"right-arrow-active"];
    }
}

- (void)createMinAndMaxDate {
    // min date will be from
    // 01/06/2016
    NSDateComponents *minDateComponent = [NSDateComponents new];
    [minDateComponent setCalendar:[NSCalendar currentCalendar]];
    [minDateComponent setDay:kDefaultDay];
    [minDateComponent setMonth:kMonthLaunch];
    [minDateComponent setYear:kYearLaunch];
    self.minDate = [minDateComponent date];
    // max date will be in the current month (avoid navigate in future months by requirement)
    self.maxDate = [self.calendarManager.dateHelper addToDate:self.startOfWeek months:0];
}

- (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"d-MM-yyyy";
    }
    return dateFormatter;
}

- (BOOL)haveEventForDay:(NSDate *)date {
    NSString *key = [[self dateFormatter] stringFromDate:date];
    if(self.eventsByDate[key] && [self.eventsByDate[key] count] > 0){
        return YES;
    }
    return NO;
}

#pragma mark - CalendarManager delegate

- (UIView<JTCalendarDay> *)calendarBuildDayView:(JTCalendarManager *)calendar {
    JTCalendarDayView *view = [JTCalendarDayView new];
    view.textLabel.font = [UIFont fontWithName:@"Montserrat-Light" size:14];
    view.textLabel.textColor = [UIColor blackColor];
    return view;
}

- (void)calendar:(JTCalendarManager *)calendar prepareDayView:(JTCalendarDayView *)dayView {
        
    //selected or same week
    if(self.dateSelected && [self.weekDates containsObject:dayView.date]){
    
        //show blue background
        dayView.circleView.hidden = NO;
        dayView.circleView.backgroundColor = [UIColor colorWithHex:@"#02A7F9"];
        dayView.textLabel.textColor = [UIColor whiteColor];
    }
    // Other month
    else if(![self.calendarManager.dateHelper date:self.calendarView.date isTheSameMonthThan:dayView.date]){
        dayView.circleView.hidden = YES;
        dayView.textLabel.textColor = [UIColor lightGrayColor];
    }
    // Another day of the current month
    else{
        dayView.circleView.hidden = YES;
        dayView.textLabel.textColor = [UIColor blackColor];
    }
    
    if([self haveEventForDay:dayView.date]){
        dayView.dotView.hidden = NO;
    }
    else{
        dayView.dotView.hidden = YES;
    }
    
    dayView.hidden = !([self.calendarManager.dateHelper date:dayView.date isEqualOrAfter:self.minDate andEqualOrBefore:[NSDate trueDate]] || [[NSDate currentWeek] containsObject:dayView.date]);
}

- (void)calendar:(JTCalendarManager *)calendar didTouchDayView:(JTCalendarDayView *)dayView {
    self.dateSelected = dayView.date;
    
    // Animation for the circleView
    dayView.circleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
    [UIView transitionWithView:dayView duration:.3 options:0 animations:^{
        dayView.circleView.transform = CGAffineTransformIdentity;
        [self.calendarManager reload];
    } completion:nil];
    
    
    // Don't change page in week mode because block the selection of days in first and last weeks of the month
    if(self.calendarManager.settings.weekModeEnabled){
        return;
    }
    
    // Load the previous or next page if touch a day from another month
    
    if(![self.calendarManager.dateHelper date:self.calendarView.date isTheSameMonthThan:dayView.date]){
        if ([self.calendarView.date compare:dayView.date] == NSOrderedAscending) {
            [self.calendarView loadNextPageWithAnimation];
        } else {
            [self.calendarView loadPreviousPageWithAnimation];
        }
    }
    
    //callback delegate date selected
    [self selectedDate:self.dateSelected];
}

#pragma mark - CalendarManager delegate - Page management

// Used to limit the date for the calendar, optional
- (BOOL)calendar:(JTCalendarManager *)calendar canDisplayPageWithDate:(NSDate *)date {
    return [self.calendarManager.dateHelper date:date isEqualOrAfter:self.minDate andEqualOrBefore:self.maxDate];
}

- (void)calendarDidLoadNextPage:(JTCalendarManager *)calendar {
    self.monthLabel.text = [calendar.date monthName];
}

- (void)calendarDidLoadPreviousPage:(JTCalendarManager *)calendar {
    self.monthLabel.text = [calendar.date monthName];
}

#pragma mark - Actions

- (IBAction)toggleCalendarAction:(id)sender {
    [self toggleCalendar];
}

- (IBAction)previousWeekAction:(id)sender {
    NSDate* previousDate = [self.calendarManager.dateHelper addToDate:self.dateSelected weeks:-1];
    [self.calendarManager setDate:previousDate];
    
    if ([self.calendarManager.dateHelper date:previousDate isEqualOrAfter:self.minDate]) {
        self.dateSelected = previousDate;
        [self previousWeek:self.dateSelected];
    }
}

- (IBAction)nextWeekAction:(id)sender {
    NSDate* nextDate = [self.calendarManager.dateHelper addToDate:self.dateSelected weeks:1];
    [self.calendarManager setDate:nextDate];
    
    if ([self.calendarManager.dateHelper date:nextDate isEqualOrBefore:self.maxDate]) {
        self.dateSelected = nextDate;
        [self nextWeek:self.dateSelected];
    }
}

@end
