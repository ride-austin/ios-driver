//
//  DriverCarInformationViewController.m
//  Ride
//
//  Created by Roberto Abreu on 17/11/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "DriverCarInformationViewController.h"

#import "DriverCarDetailsViewController.h"
#import "NSString+Utils.h"
#import "RACity.h"
#import "VehicleInformationHeaderTableViewCell.h"
#import "VehicleInformationRequirementTableViewCell.h"
#import "YearViewController.h"

@interface DriverCarInformationViewController () <UITableViewDataSource>
@end

@implementation DriverCarInformationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [@"Vehicle Information" localized];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(carAdded:) name:@"kCarAdded" object:nil];
    
    [self configureTable];
    [self configureRegistrationConfig];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self hideHUD];
}

- (void)configureTable {
    self.tblVehicleInformation.estimatedRowHeight = 44;
    self.tblVehicleInformation.rowHeight = UITableViewAutomaticDimension;
    [self.tblVehicleInformation setNeedsLayout];
    [self.tblVehicleInformation layoutIfNeeded];
}

- (void)configureRegistrationConfig {
    [self.tblVehicleInformation reloadData];
    [UIView animateWithDuration:0.2 animations:^{
        self.vContainer.alpha = 1.0;
    }];
}

- (IBAction)continuePressed:(id)sender {
    YearViewController *yVC = [[YearViewController alloc] init];
    yVC.minYear = self.regConfig.cityDetail.minCarYear;
    yVC.userData = self.userData;
    
    UINavigationController *carsNav = [[UINavigationController alloc] initWithRootViewController:yVC];
    [self.navigationController presentViewController:carsNav animated:YES completion:nil];
}

#pragma mark - Car Added Notification

- (void)carAdded:(NSNotification*)notification {

    DriverCarDetailsViewController *driverCarDetailsViewController = [[DriverCarDetailsViewController alloc] initWithUserData:self.userData andRegistrationConfig:self.regConfig];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:driverCarDetailsViewController animated:YES];
    });
}

#pragma mark - UITABLEVIEW DATASOURCE

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return super.regConfig.cityDetail ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return super.regConfig.cityDetail.requirements.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row == 0) {
        
        //Header Information
        VehicleInformationHeaderTableViewCell *cell = (VehicleInformationHeaderTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"VehicleHeaderCell" forIndexPath:indexPath];
       
        cell.lblDescription.text = super.regConfig.cityDetail.cityDescription;
        cell.lblDescription.font = [UIFont fontWithName:@"Montserrat-Light" size:14.0];
    
        return cell;
        
    } else {
        
        //Requirements
        NSString *requirement = [super.regConfig.cityDetail.requirements objectAtIndex:indexPath.row - 1];
        VehicleInformationRequirementTableViewCell *cell = (VehicleInformationRequirementTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"VehicleRequirementCell" forIndexPath:indexPath];
        cell.lblRequirement.text = requirement;
        return cell;
    }
}

@end
