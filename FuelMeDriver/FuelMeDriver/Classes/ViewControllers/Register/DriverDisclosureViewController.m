//
//  RDDriverDisclosureViewController.m
//  RideDriver
//
//  Created by Adriano Alencar on 19/05/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "DriverDisclosureViewController.h"
#import "WebViewController.h"
#import "RideUser.h"
#import "User.h"
#import "NetworkManager.h"

@interface DriverDisclosureViewController ()

@property (weak, nonatomic) IBOutlet UIButton *imgCheckBox;
@property (nonatomic,assign)BOOL check;

@end

@implementation DriverDisclosureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO];
    self.edgesForExtendedLayout = UIRectEdgeNone;    
    self.check = NO;
}

#pragma mark- IBACTIONS

- (IBAction)needHelp:(id)sender {
    [self launchBrowser:@"http://www.rideaustin.com/contact/" title:@"Help"];
}

- (IBAction)btnCheckPressed:(id)sender {
    UIButton *button = (UIButton*)sender;
    if (button.selected) {
        button.selected = NO;
    } else {
        button.selected = YES;
    }
}

- (IBAction)btnContinuePressed:(id)sender {
    if (self.imgCheckBox.selected) {
        
        [self showHUD];
        [[NetworkManager sharedInstance] postPath:@"/rest/driversdata"
                                           params:self.userData
                                    completeBlock:^(NSString *resourceId, NSInteger statusCode, NSError *error) {
            if (error) {
                [self hideHUD];
                [self showError: error];
            } else {
                Car *car = [RideUser car];
                NSDictionary *params = @{@"color":car.color,
                                         @"license":car.license,
                                         @"make":car.make,
                                         @"model":car.model,
                                         @"year":car.year,
                                         @"favorite":car.favorite,
                                         @"fuelType":car.fuelType};
                
                NSString *path = [NSString stringWithFormat:@"%@/%@", UserResourcePath, @"cars"];
                [[NetworkManager sharedInstance] postPath:path
                                                   params:params
                                            completeBlock:^(NSString *resourceId, NSInteger statusCode, NSError *error) {
                                                if (error) {
                                                    [self showError: error];
                                                } else {
                                                    [[NetworkManager sharedInstance] getCurrentDriverWithCompletion:^(Driver *driver, NSError *error){
                                                        if (error) {
                                                            [self showError: error];
                                                        } else {                                                            
                                                            [self hideHUD];
                                                            [self.navigationController popToRootViewControllerAnimated:YES];
                                                            [AppDelegate loginFrom:self withCompletion:nil];
                                                        }
                                                    }];
                                                }
                                            }];
        
            }}];
    } else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Ride Austin"
                                                       message:@"Please agree to continue "
                                                      delegate:nil
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles: nil];
        [alert show];
    }
}
@end

