//
//  DriverPhotoViewController.m
//  Ride
//
//  Created by Carlos Alcala on 9/16/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "DriverPhotoViewController.h"

#import "RASessionManager.h"
#import "RideDriverConstants.h"
#import "NSString+Utils.h"
#import "RAAlertManager.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <UIActivityIndicator_for_SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>

@interface DriverPhotoViewController ()

@property (nonatomic, strong) RAPhotoPickerControllerManager *pickerManager;

@end

@implementation DriverPhotoViewController

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [@"Update Driver Photo" localized];
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:[@"SAVE" localized] style:UIBarButtonItemStylePlain target:self action:@selector(save)];
    [self.navigationItem setRightBarButtonItem:saveButton];
    
    [self loadUserImage];
}

#pragma mark - Load Image Function

- (void)loadUserImage {
    __weak __typeof__(self) weakSelf = self;
    RADriverDataModel *driver = [RASessionManager shared].currentSession.driver;
    [self.imagePhoto setImageWithURL:driver.photoUrl placeholderImage:nil options:0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
         //assign image if no error
         if (!error) {
             // assign image
             weakSelf.imagePhoto.image = image;
         }
    } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
}

#pragma mark- Button Action

- (IBAction)takePhotoAction:(id)sender {
    __weak __typeof__(self) weakSelf = self;
    self.pickerManager = [RAPhotoPickerControllerManager pickerManager];
    [self.pickerManager showPickerControllerFromViewController:self sender:sender allowEditing:YES finishedBlock:^(UIImage *image, NSError *error) {
        BOOL valid = [weakSelf isImageValid:image];
        if (valid) {
            CGFloat maxArea = 480000;
            image = [UIImage imageWithImage:image scaledToMaxArea:maxArea];
        }
        
        weakSelf.imagePhoto.image = valid ? image : nil;
        weakSelf.photo            = valid ? image : nil;
    }
    accessDeniedBlock:^(NSString *errorTitle, NSString *errorMessage) {
        [RAAlertManager showAlertWithTitle:errorTitle message:errorMessage];
    }];
}

#pragma mark- UTilities
//
//    RA-2266
//    iPhone 6/6+, iPhone 5/5S, iPhone 4S(8 MP) - 3264 x
//    2448 pixels
//    iPhone 4, iPad 3, iPodTouch(5 MP) - 2592 x 1936 pixels
//    Size Validation based on the minium iPhone4/iPod Photo Resolutions above
//
- (BOOL)isImageValid:(UIImage *)image {
    if (image && [image imageValidSizeForMinArea:190*250]) {
        return YES;
    } else {
        [RAAlertManager showErrorWithAlertItem:[@"Please upload a High Quality Photo with a minimum size of 190x250 pixels to be readable." localized]
                                    andOptions:[RAAlertOption optionWithTitle:[@"Invalid Size" localized] andState:StateActive]];
        return NO;
    }
}

- (void)save {
    //photo should be mandatory to save
    if (!self.photo) {
        [RAAlertManager showErrorWithAlertItem:[@"Please upload a valid photo to continue." localized]
                                    andOptions:[RAAlertOption optionWithTitle:[@"Driver Photo" localized] andState:StateActive]];
        return;
    }
    
    
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:[@"NO" localized] style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:[@"YES" localized] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
       NSData *imageData = [self.photo compressToMaxSize:300000];
        
        __weak __typeof__(self) weakSelf = self;
        [weakSelf showHUD];
        
        //Driver Photo Update API callback
        [[RASessionManager shared] updateDriverPhoto:imageData withCompletion:^(NSError * _Nullable error) {
                                                   [weakSelf hideHUD];
                                                   //[self.navigationController.view setUserInteractionEnabled:YES];
                                                   self.navigationController.interactivePopGestureRecognizer.enabled = YES;

                                                   if (!error) {
                                                       [RAAlertManager showAlertWithTitle:[@"Driver Photo" localized] message:[@"Photo updated successfully" localized] options:[RAAlertOption optionWithState:StateActive]];
                                                       [self.navigationController popViewControllerAnimated:YES];
                                                   } else {
                                                       [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive]];
                                                   }
                                               }
         ];
    }];
    
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[ConfigurationManager appName] message:[@"Are you sure your Driver Profile Photo clearly shows your face and eyes without sunglasses?" localized] preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:noAction];
    [alert addAction:yesAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
