//
//  WeeklyEarningsViewController.h
//  RideDriver
//
//  Created by Carlos Alcala on 7/18/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "BaseViewController.h"
#import "JTCalendar.h"

@protocol WeeklyCalendarDelegate <NSObject>

- (void)selectedDate:(NSDate*)date;
- (void)nextWeek:(NSDate*)date;
- (void)previousWeek:(NSDate*)date;

@end


@interface WeeklyEarningsViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource, WeeklyCalendarDelegate, JTCalendarDelegate>

//IBOutlets
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *weekLabel;
@property (weak, nonatomic) IBOutlet UIButton *showCalendarButton;
@property (weak, nonatomic) IBOutlet UIButton *lastWeekButton;
@property (weak, nonatomic) IBOutlet UIButton *nextWeekButton;
@property (weak, nonatomic) IBOutlet UIImageView *nextWeekIcon;
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;
@property (weak, nonatomic) IBOutlet JTHorizontalCalendarView *calendarView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *calendarHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *monthLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *calendarContainerView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

//Delegate
@property (weak, nonatomic) id <WeeklyCalendarDelegate> delegate;

//Properties
@property (strong, nonatomic) JTCalendarManager *calendarManager;
@property (strong, nonatomic) NSDate *startOfWeek;
@property (strong, nonatomic) NSDate *endOfWeek;

@property (strong, nonatomic) NSDate *minDate;
@property (strong, nonatomic) NSDate *maxDate;
@property (strong, nonatomic) NSDate *dateSelected;

@property (strong, nonatomic) NSMutableDictionary *eventsByDate;
@property (strong, nonatomic) NSMutableDictionary *dataByDate;

//Properties
@property (strong, nonatomic) NSDate *currentDate;
@property (strong, nonatomic) NSMutableArray *weekDates;
@property (strong, nonatomic) NSMutableArray *weekDaysData;
@property (strong, nonatomic) NSMutableArray *rides;
@property (strong, nonatomic) NSArray *currentWeek;

@property (assign, nonatomic) CGFloat expandedCalendarHeight;

/**
 *  @brief total driver payment
 */
@property (strong, nonatomic) NSNumber *total;
@property (strong, nonatomic) NSNumber *rating;
@property (strong, nonatomic) NSNumber *online;


//Actions
- (IBAction)previousWeekAction:(id)sender;
- (IBAction)toggleCalendarAction:(id)sender;
- (IBAction)nextWeekAction:(id)sender;

@end
