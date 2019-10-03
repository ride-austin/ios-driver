//
//  DirectConnectViewController.m
//  RideDriver
//
//  Created by Roberto Abreu on 11/13/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "DirectConnectViewController.h"

#import "ConfigurationManager.h"
#import "RADriverDataModel.h"
#import "RADriversAPI.h"
#import "RASessionManager.h"
#import "RAAlertManager.h"

@implementation DirectConnectViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUI];
}

#pragma mark - Configure UI

- (void)configureUI {
    ConfigDirectConnect *configDirectConnect = [ConfigurationManager shared].global.configDirectConnect;
    self.lblDescription.text = configDirectConnect.directConnectDescription;
    
    RADriverDataModel *currentDriver = [RASessionManager shared].currentSession.driver;
    self.lblDirectConnectCode.text = currentDriver.directConnectId;
}

- (IBAction)btnRequestNewDriverConnectIdTapped:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Reset driver id" message:@"Your direct connect id will be replaced with a new one permanently. Do you want to continue?" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Get new id" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self resetDirectConnectID];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)resetDirectConnectID {
    [self showHUD];
    __weak DirectConnectViewController *weakSelf = self;
    [RADriversAPI getNewDriverConnectIdWithCompletion:^(NSString *driverConnectId, NSError *error) {
        [weakSelf hideHUD];
        if (error) {
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateAll andShownOption:AllowNetworkError]];
        } else {
            [weakSelf configureUI];
        }
    }];
}

@end
