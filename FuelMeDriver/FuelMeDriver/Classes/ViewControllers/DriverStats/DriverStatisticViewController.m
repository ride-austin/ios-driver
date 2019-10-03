//
//  DriverStatisticViewController.m
//  RideDriver
//
//  Created by Roberto Abreu on 7/27/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "DriverStatisticViewController.h"

#import "DriverStatisticTableViewCell.h"
#import "NSString+Utils.h"
#import "RADriverStatDataModel.h"
#import "RADriversAPI.h"
#import "RASessionManager.h"
#import "UIColor+HexUtils.h"
#import "RAAlertManager.h"

#import <LGRefreshView/LGRefreshView.h>

@interface DriverStatisticViewController ()

//IBOutlets
@property (weak, nonatomic) IBOutlet UITableView *tblStatistics;

//Properties
@property (strong, nonatomic) NSArray<RADriverStatDataModel *> *driverStatistics;
@property (strong, nonatomic) LGRefreshView *refreshView;

@end

@implementation DriverStatisticViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureNavigationBar];
    [self configurePullToRefresh];
    
    __weak __typeof__(self) weakself = self;
    [self showHUD];
    [self updateStatsWithCompletion:^{
        [weakself hideHUD];
    }];
}

- (NSString *)driverID {
    if (!_driverID) {
        _driverID = [RASessionManager shared].currentSession.driver.modelID.stringValue;
    }
    return _driverID;
}

#pragma mark - Configure UI

- (void)configureNavigationBar {
    CGFloat btnContactWidth = [UIScreen mainScreen].bounds.size.width <= 320 ? 68.0 : 80.0;
    UIButton *btnSupport = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnContactWidth, 28.0)];
    [btnSupport setTitle:[@"Support" localized] forState:UIControlStateNormal];
    [btnSupport.titleLabel setFont:[UIFont fontWithName:@"Montserrat-Regular" size:12.0]];
    [btnSupport setTitleColor:[UIColor colorWithHex:@"2C323C"] forState:UIControlStateNormal];
    [btnSupport addTarget:self action:@selector(supportTapped:) forControlEvents:UIControlEventTouchUpInside];
    btnSupport.layer.cornerRadius = 14.0;
    btnSupport.layer.borderWidth = 0.7;
    btnSupport.layer.borderColor = [UIColor colorWithHex:@"#DFDFDF"].CGColor;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnSupport];
}

- (void)configurePullToRefresh {
    __weak __typeof__(self) weakself = self;
    self.refreshView = [LGRefreshView refreshViewWithScrollView:self.tblStatistics refreshHandler:^(LGRefreshView *refreshView) {
        [weakself updateStatsWithCompletion:^{
            [refreshView endRefreshing];
        }];
    }];
    self.refreshView.tintColor = [UIColor darkGrayColor];
    self.tblStatistics.scrollEnabled = YES;
}

#pragma mark - API

- (void)updateStatsWithCompletion:(void(^)(void))completion {
    __weak DriverStatisticViewController *weakSelf = self;
    [RADriversAPI getStatisticForDriverWithId:self.driverID completion:^(NSArray<RADriverStatDataModel *> *driverStatistics, NSError *error) {
        if (error) {
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateAll]];
        } else {
            weakSelf.driverStatistics = driverStatistics;
        }
        completion();
    }];
}

- (void)setDriverStatistics:(NSArray<RADriverStatDataModel *> *)driverStatistics {
    _driverStatistics = driverStatistics;
    [self.tblStatistics reloadData];
}

#pragma mark - IBActions

- (IBAction)supportTapped:(id)sender {
    [self showMessageViewWithRideID:nil];
}

#pragma mark - TableView Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.driverStatistics.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DriverStatisticTableViewCell *cell = (DriverStatisticTableViewCell*)[tableView dequeueReusableCellWithIdentifier:DriverStatisticTableViewCell.className forIndexPath:indexPath];
    
    RADriverStatDataModel *driverStat = self.driverStatistics[indexPath.row];
    cell.lblTitle.text = driverStat.name;
    cell.lblDescription.text = driverStat.statDescription;
    cell.lblPercent.text = [NSString stringWithFormat:@"%d%%", (int)driverStat.rate];
    
    return cell;
}

@end
