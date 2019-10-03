//
//  DriverCarFrontViewController.m
//  Ride
//
//  Created by Roberto Abreu on 12/26/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "DriverCarPhotoViewController.h"

#import "DriverCarPhotoViewModel.h"
#import "NSString+Ride.h"
#import "UIImage+Ride.h"
#import "NSString+Utils.h"
#import "RAAlertManager.h"

@interface DriverCarPhotoViewController ()

@property (nonatomic, strong) RAPhotoPickerControllerManager *picturePickerManager;
@property (nonatomic) DriverCarPhotoViewModel *driverCarPhotoViewModel;

@end

@implementation DriverCarPhotoViewController

- (id)initWithUserData:(NSMutableDictionary*)userData registrationConfig:(ConfigRegistration *)regConfig carPhotoType:(CarPhotoType)carPhotoType {
    if (self = [super init]) {
        self.userData = userData;
        self.driverCarPhotoViewModel = [[DriverCarPhotoViewModel alloc] initWithUserData:userData registrationConfig:regConfig carPhotoType:carPhotoType];
        self.regConfig = regConfig;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [@"Vehicle Information" localized];
    [self setupUI];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:[@"NEXT" localized] style:UIBarButtonItemStylePlain target:self action:@selector(next)];
    [self.navigationItem setRightBarButtonItem:doneButton];
    
    //picker manager
    self.picturePickerManager = [RAPhotoPickerControllerManager pickerManager];
}

- (void)setupUI{
    self.lblDescription.text = self.driverCarPhotoViewModel.carPhotoDescription;
    self.lblDescription.font = [UIFont fontWithName:@"Montserrat-Light" size:19.0];
    self.imagePhoto.image = self.driverCarPhotoViewModel.carPhotoDefaultImage;
}

#pragma mark- Button Action

- (IBAction)takePhotoAction:(id)sender {
    // show the photo picker
    __weak DriverCarPhotoViewController *weakSelf = self;
    
    //RA-4280 native control photo picker
    [self.picturePickerManager showPickerControllerFromViewController:self sender:sender allowEditing:YES finishedBlock:^(UIImage *image, NSError *error) {
        BOOL valid = [weakSelf isImageValid:image];
        if (valid) {
            CGFloat maxArea = 480000;
            image = [UIImage imageWithImage:image scaledToMaxArea:maxArea];
        }
        
        weakSelf.imagePhoto.image = valid ? image : nil;
        weakSelf.photo = valid ? image : nil;
    }
    accessDeniedBlock:^(NSString *errorTitle, NSString *errorMessage) {
        [RAAlertManager showAlertWithTitle:errorTitle message:errorMessage];
    }];
}

- (void)next {
    
    if (![[NetworkManager sharedInstance] isNetworkReachable]) {
        [RAAlertManager showErrorWithAlertItem:[@"Internet Connection is down. Please try again later." localized]
                                    andOptions:[RAAlertOption optionWithTitle:[@"Network Offline" localized] andState:StateActive]];
        return;
    }
    
    //RA-2642 - photo should be mandatory to continue
    if (!self.photo) {
        [RAAlertManager showErrorWithAlertItem:[@"Please upload the car photo required to continue." localized]
                                    andOptions:[RAAlertOption optionWithTitle:[@"Driver Signup" localized] andState:StateActive]];
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[ConfigurationManager appName] message:self.driverCarPhotoViewModel.carPhotoAlertDescription preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:[@"NO" localized] style:UIAlertActionStyleCancel handler:nil]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:[@"YES" localized] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSData *imageData = [self.photo compressToMaxSize:300000];
        NSString *carPhotoType = [NSString stringWithPhotoType:self.driverCarPhotoViewModel.carPhotoType];
        self.driverCarPhotoViewModel.userData[carPhotoType] = imageData;
    
        UIViewController *controller = self.driverCarPhotoViewModel.routeController;
        [self.navigationController pushViewController:controller animated:YES];
        
    }]];
    
    [self.navigationController presentViewController:alertController animated:YES completion:nil];
}

- (BOOL)isImageValid:(UIImage *)image {
    if (image && [image imageValidSizeForMinArea:190*250]) {
        return YES;
    } else {
        [RAAlertManager showErrorWithAlertItem:[@"Please upload a High Quality Photo with a minimum size of 190x250 pixels to be readable." localized]
                                    andOptions:[RAAlertOption optionWithTitle:[@"Invalid Size" localized] andState:StateActive]];
        return NO;
    }
}

@end
