//
//  ReferFriendViewController.m
//  RideDriver
//
//  Created by Carlos Alcala on 9/13/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "ReferFriendViewController.h"

#import "NSString+Utils.h"

@interface ReferFriendViewController () <DriverStateDelegate>

@end

@implementation ReferFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = [@"Refer a Friend" localized];
    [DriverManager shared].delegate = self;
    [self configureUI];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [DriverManager shared].delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationItem.titleView = nil;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.toggleStatusButton layoutIfNeeded];
        self.toggleStatusButton.layer.cornerRadius = self.toggleStatusButton.frame.size.height / 2;
    });
}

- (void)configureUI {
    
    Car *car = [RASessionManager shared].currentSession.driver.selectedCar;
    
    NSString* carData = [NSString stringWithFormat:@"%@ %@ %@", car.make, car.model, car.license];
    
    self.carLabel.text = carData;
    
    [self.toggleStatusButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.toggleStatusButton.titleLabel setFont:[UIFont fontWithName:@"Montserrat-Regular" size:15]];
    
    [self updateToogleButton];
}

#pragma mark - DriverStateDelegate

- (void)driverManagerDidUpdateDriverState:(DriverState)driverState fromPreviousDriverState:(DriverState)previousDriverState withRide:(RARideDataModel * _Nullable)rideDataModel {
    [self updateToggleButtonByState:driverState];
}

- (void)driverManagerDidUpdateRide:(RARideDataModel *)rideDataModel {
    
}

- (void)updateToogleButton {
    BOOL online = [[DriverManager shared] isDriverOnline];
    
    UIColor  *green     = [UIColor colorWithRed:1/255.0 green:188/255.0 blue:0 alpha:1];
    UIColor  *red       = [UIColor colorWithRed:1       green: 17/255.0 blue:0 alpha:1];
    UIColor  *bgColor   = online ? green:red;
    NSString *title     = online ? [@"ONLINE" localized] : [@"OFFLINE" localized];
    
    self.toggleStatusButton.hidden = NO;
    [self.toggleStatusButton setBackgroundColor:bgColor];
    [self.toggleStatusButton setTitle:title forState:UIControlStateNormal];
}

- (void)updateToggleButtonByState:(DriverState)driverState {
    switch (driverState) {
        case OfflineDriverState:
        case AvailableDriverState:
            [self updateToogleButton];
            break;
        case GoingToPickUpDriverState:
        case ArrivingToPickUpDriverState:
        case OnTripDriverState:
        case AcceptingRequest:
            self.toggleStatusButton.hidden = YES;
            
            break;
        case InvalidDriverState:
            break;
    }
}

@end
