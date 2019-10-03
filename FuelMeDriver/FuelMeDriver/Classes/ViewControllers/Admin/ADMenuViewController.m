//
//  ADMenuViewController.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 8/12/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "ADMenuViewController.h"

#import "ADMenuItem.h"
#import "CarSelectionViewController.h"
#import "UIStoryboard+UniqueViewControllerFactory.h"
#import "WeeklyEarningsViewController.h"
#import "RAAlertManager.h"

@interface ADMenuViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSArray<ADMenuItem *>*menuItems;

@end

@implementation ADMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureItems];
}

- (void)configureItems {
    __weak ADMenuViewController *weakself = self;
    ADMenuItem *carList = [ADMenuItem itemWithTitle:@"Car List" andDidTapCellBlock:^(UITableViewCell *cell) {
        [weakself showCarsForDriver:weakself.driverID];
    }];
    
    self.menuItems = @[carList];
}

- (void)showCarsForDriver:(NSString *)driverID {
    [super showHUD];
    NSNumber *cityId = @(1);
    RACity *registeredCity = [ConfigurationManager getCityWithID:cityId];
    [NetworkManager getCityDetailWithID:cityId withCompletion:^(RACityDetail *cityDetail, NSError *error) {
        [super hideHUD];
        if (error) {
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive]];
        } else {
            CarSelectionViewController *vc = (CarSelectionViewController *)[UIStoryboard viewControllerForID:CarSelectionViewController.className];
            [vc configureWithCityDetail:cityDetail
                         registeredCity:registeredCity
                            andDriverID:driverID];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];
}

@end

@interface ADMenuViewController (TableView) <UITableViewDelegate, UITableViewDataSource>

@end

@implementation ADMenuViewController (TableView)

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ADMenuItem *item = self.menuItems[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[UITableViewCell className] forIndexPath:indexPath];
    cell.textLabel.text = item.title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    ADMenuItem *item = self.menuItems[indexPath.row];
    item.didTapCellBlock(cell);
}

@end
