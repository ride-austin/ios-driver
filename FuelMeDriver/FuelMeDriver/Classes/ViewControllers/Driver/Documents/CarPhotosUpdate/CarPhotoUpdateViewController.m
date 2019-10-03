//
//  DriverCarBackViewController.m
//  Ride
//
//  Created by Carlos Alcala on 9/21/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "CarPhotoUpdateViewController.h"

#import "NSString+Utils.h"
#import "UIImage+Ride.h"
#import "RAAlertManager.h"

@interface CarPhotoUpdateViewController ()

@property (nonatomic, strong) RAPhotoPickerControllerManager *picturePickerManager;
@property (nonatomic, strong) NSMutableDictionary *userData;
@property (weak, nonatomic) IBOutlet UITextView *txtDetail;

@end

@implementation CarPhotoUpdateViewController

- (id)initWithUserData:(NSDictionary*)userData {
    self = [super init];
    if (self) {
        self.userData = [NSMutableDictionary dictionaryWithDictionary:userData];
        [self.navigationController setNavigationBarHidden:NO];
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [@"Vehicle Information" localized];
    self.userData = [NSMutableDictionary new];

    self.saveButton = [[UIBarButtonItem alloc] initWithTitle:[@"SAVE" localized] style:UIBarButtonItemStylePlain target:self action:@selector(next)];
    [self.navigationItem setRightBarButtonItem:self.saveButton];
    
    //picker manager
    self.picturePickerManager = [RAPhotoPickerControllerManager pickerManager];
    
    [self updateViewAccordingToType];
}

#pragma mark- Button Action

- (IBAction)takePhotoAction:(id)sender {
    [self takePhoto:sender];
}

#pragma mark- Utilities

- (void)takePhoto:(UIButton *)sender {
    // show the photo picker
    __weak typeof(self) weakSelf = self;
    
    //RA-4280 native control photo picker
    [self.picturePickerManager showPickerControllerFromViewController:self sender:sender allowEditing:YES finishedBlock:^(UIImage *picture, NSError *error) {
        BOOL valid = [weakSelf isImageValid:picture];
        if (valid) {
            CGFloat maxArea = 480000;
            picture = [UIImage imageWithImage:picture scaledToMaxArea:maxArea];
        }
        
        weakSelf.imagePhoto.image = valid ? picture : nil;
        weakSelf.photo            = valid ? picture : nil;
    }
    accessDeniedBlock:^(NSString *errorTitle, NSString *errorMessage) {
        [RAAlertManager showAlertWithTitle:errorTitle message:errorMessage];
    }];
}

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
        [RAAlertManager showErrorWithAlertItem:[@"Please upload a High Quality Photo with a minimum size of 190x250 pixels to be readable." localized] andOptions:[RAAlertOption optionWithTitle:[@"Invalid Size" localized] andState:StateActive]];
        return NO;
    }
}

- (void)next {
    
    if (![[NetworkManager sharedInstance] isNetworkReachable]) {
        [RAAlertManager showErrorWithAlertItem:[@"Internet Connection is down. Please try again later." localized] andOptions:[RAAlertOption optionWithTitle:[@"Network Offline" localized] andState:StateActive]];

        return;
    }
    
    //RA-2642 - photo should be mandatory to continue
    if (!self.photo) {
        [RAAlertManager showErrorWithAlertItem:[@"Please upload the car photo required to continue." localized] andOptions:[RAAlertOption optionWithTitle:@"" andState:StateActive]];
        return;
    }
    
    [self save];

}

#pragma mark- Update

- (void)save {
    //photo should be mandatory to save
    if (!self.photo) {
        [RAAlertManager showErrorWithAlertItem:[@"Please upload a valid photo to continue." localized] andOptions:[RAAlertOption optionWithTitle:@"" andState:StateActive]];
        return;
    }
    
    
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:[@"NO" localized] style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:[@"YES" localized] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        //First need to delete prev one
        if (self.carPhoto.photoID) {
            [[NetworkManager sharedInstance] deleteCarPhotoWithCarPhotoID:self.carPhoto.photoID andCompletionBlock:^(NSDictionary *object, NSError *error) {
                
                if (!error) {
                    // now add new one
                    [self addNewPhoto];
                }else{
                    [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive]];
                }
            }];
        } else {
            [self addNewPhoto];
        }
    }];
    
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[ConfigurationManager appName] message:[self getAlertTextForCurrentCarPhoto] preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:noAction];
    [alert addAction:yesAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)addNewPhoto {
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    NSData *imageData = [self.photo compressToMaxSize:300000];
    self.userData[@"photoData"] = imageData; // pass in the data for the Multipart form POST
    
    self.saveButton.enabled = NO;
    
    __weak typeof(self) weakSelf = self;
    [weakSelf showHUD];
    
    //Driver Photo Update API callback
    [[NetworkManager sharedInstance] postCarPhotoWithParams:self.userData andCarID:self.carID andCarType:[NSString getPhotoTypeStringWithCarPhotoType:self.carPhoto.type] uploadCompleteBlock:^(NSString *photoUrl, NSError *error){
        [weakSelf hideHUD];
        //[self.navigationController.view setUserInteractionEnabled:YES];
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        
        if (!error) {
            weakSelf.saveButton.enabled = YES;
            [RAAlertManager showAlertWithTitle:@"" message:[@"Photo updated successfully" localized]];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        } else {
            weakSelf.saveButton.enabled = YES;
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive]];
            DBLog(@"Update Photo Error: %@",error);
        }
    }];

}

#pragma mark- UI Dynamics

- (void)updateViewAccordingToType {
    self.txtDetail.text = [self getLabelTextForCurrentCarPhoto];
    [self.imagePhoto setImage:self.carPhoto.placeHolderLarge];
    self.txtDetail.font = [UIFont fontWithName:@"Montserrat-Light" size:19.0];
}

- (NSString*)getLabelTextForCurrentCarPhoto {
    switch (self.carPhoto.type) {
        case FrontPhoto:
            return [@"Front left angle, showing the license plate" localized];
        case BackPhoto:
            return [@"Back right angle showing plate" localized];
        case InsidePhoto:
            return [@"Inside photo showing the entire back seat" localized];
        case TrunkPhoto:
            return [@"Open trunk, full view" localized];
        default:
            return @"";
    }
}

- (NSString*)getAlertTextForCurrentCarPhoto {
    switch (self.carPhoto.type) {
        case FrontPhoto:
            return [@"Are you sure the Photo is clearly taken from the Front left angle side and shows your license plate?" localized];
        case BackPhoto:
            return [@"Are you sure the Photo is clearly taken from the Back right angle side and shows your license plate?" localized];
        case InsidePhoto:
            return [@"Are you sure the Photo is clearly taken from Inside the car showing the entire back seat?" localized];
        case TrunkPhoto:
            return [@"Are you sure the Photo is showing the Trunk open in full view?" localized];
        default:
            return @"";
    }
}

@end
