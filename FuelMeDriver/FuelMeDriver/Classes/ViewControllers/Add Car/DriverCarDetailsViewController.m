//
//  DriverCarDetailsViewController.m
//  Ride
//
//  Created by Abdul Rehman on 16/05/2016.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "DriverCarDetailsViewController.h"

#import "CarSelectionViewController.h"
#import "DocumentManager.h"
#import "InsuranceDocumentViewController.h"
#import "NSString+Ride.h"
#import "RideUser.h"
#import "YearViewController.h"
#import "NSString+Utils.h"
#import "RAAlertManager.h"

@interface DriverCarDetailsViewController ()

@property (nonatomic, strong) NSMutableDictionary *userData;
@property (nonatomic) __block Car *carCreated;

@end

@implementation DriverCarDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [@"Vehicle Information" localized];
    [self configureUI];
}

- (id)initWithUserData:(NSMutableDictionary*)userData andRegistrationConfig:(ConfigRegistration *)regConfig {
    self = [super init];
    if (self) {
        self.userData = userData;
        self.regConfig = regConfig;
    }
    return self;
}

- (void)configureUI {
    self.carDescription.font = [UIFont fontWithName:@"Montserrat-Light" size:14.0];
    self.carDescription.text = self.regConfig.cityDetail.addCarSuccessMessage;
    
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:[@"SAVE" localized] style:UIBarButtonItemStylePlain target:self action:@selector(next)];
    [self.navigationItem setRightBarButtonItem:nextButton];
}

- (void)next {
    
    if (![[NetworkManager sharedInstance] isNetworkReachable]) {
        [RAAlertManager showErrorWithAlertItem:[@"Internet Connection is down. Please try again later." localized]
                                    andOptions:[RAAlertOption optionWithTitle:[@"Network Offline" localized] andState:StateActive]];
        return;
    }
    
    NSString *driverId = [RASessionManager shared].currentSession.driver.modelID.stringValue;
    
    [self showHUD];
    __weak DriverCarDetailsViewController *weakSelf = self;
    [self uploadCarInformationWithDriverId:driverId andCompletion:^(NSError *error) {
        [self hideHUD];
        if (!error) {
            InsuranceDocumentViewController *insuranceDocumentViewController = (InsuranceDocumentViewController*)[self createViewControllerFromStoryboard:@"PersonalDocuments" withIdentifier:@"InsuranceDocumentViewController"];
            insuranceDocumentViewController.regConfig = self.regConfig;
            insuranceDocumentViewController.isNewCar = YES;
            insuranceDocumentViewController.selectedCar = weakSelf.carCreated;
            [weakSelf.navigationController pushViewController:insuranceDocumentViewController animated:YES];
        }
        else {
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive]];
        }
        
    }];
}

- (NSDictionary*)carParams {
    Car *car = [RideUser car];
    return @{
             @"color" : car.color,
             @"license":car.license,
             @"make"   :car.make,
             @"model"  :car.model,
             @"year"   :car.year
            };
}

#pragma mark- CAR CREATION

- (void)uploadCarInformationWithDriverId:(NSString*)driverId andCompletion:(CarCreationCompletionBlock)completion {
    
    dispatch_group_t group = dispatch_group_create();
    __block NSError *carInformationError = nil;
    __weak DriverCarDetailsViewController *weakSelf = self;
   
    //Default Car Photo Currently Added From Front Car photo
    NSString *keyPhoto = [NSString stringWithPhotoType:FrontPhoto];
    NSData *carPhoto = self.userData[keyPhoto];
    NSString *path = [NSString stringWithFormat:@"drivers/%@/cars", driverId];
    NSData *carData = [NSJSONSerialization dataWithJSONObject:[self carParams] options:0 error:NULL];
    
    //Create Car
    if (!self.carCreated) {
        dispatch_group_enter(group);
        [[NetworkManager sharedInstance] addCarInformationWithPath:path carData:carData photoData:carPhoto completeBlock:^(Car *car, NSError *error) {
            if (error) {
                carInformationError = error;
            } else {
                weakSelf.carCreated = car;
            }
            dispatch_group_leave(group);
        }];
    }

    //Notify
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (carInformationError) {
            completion(carInformationError);
        }else{
            [self uploadCarPhotoWithCarId:self.carCreated.modelID.stringValue andCompletion:completion];
        }
    });
}

- (void)uploadCarPhotoWithCarId:(NSString*)carId andCompletion:(CarCreationCompletionBlock)completion {
    
    dispatch_group_t carPhotoGroup = dispatch_group_create();
    __block NSError *uploadError = nil;
    
    //Upload Frontp
    dispatch_group_enter(carPhotoGroup);
    [self uploadCarPhotoWithCarId:carId photoType:FrontPhoto andCompletion:^(id object, NSString *filePath, NSError *error) {
        if (error) {
            uploadError = error;
        }
        dispatch_group_leave(carPhotoGroup);
    }];
    
    //Upload Back
    dispatch_group_enter(carPhotoGroup);
    [self uploadCarPhotoWithCarId:carId photoType:BackPhoto andCompletion:^(id object, NSString *filePath, NSError *error) {
        if (error) {
            uploadError = error;
        }
        dispatch_group_leave(carPhotoGroup);
    }];
    
    //Upload Inside
    dispatch_group_enter(carPhotoGroup);
    [self uploadCarPhotoWithCarId:carId photoType:InsidePhoto andCompletion:^(id object, NSString *filePath, NSError *error) {
        if (error) {
            uploadError = error;
        }
        dispatch_group_leave(carPhotoGroup);
    }];
    
    //Upload Trunk
    dispatch_group_enter(carPhotoGroup);
    [self uploadCarPhotoWithCarId:carId photoType:TrunkPhoto andCompletion:^(id object, NSString *filePath, NSError *error) {
        if (error) {
            uploadError = error;
        }
        dispatch_group_leave(carPhotoGroup);
    }];
    
    //Upload Car Sticker
    if (self.userData[@"inspectionSticker"]) {
        dispatch_group_enter(carPhotoGroup);
        NSNumber *cityId = [RASessionManager shared].currentSession.driver.cityId;
        UIImage *inspectionStickerImage = self.userData[@"inspectionSticker"];
        NSDate *inspectionStickerExpirationDate = self.userData[@"inspectionStickerExpirationDate"];
        [DocumentManager uploadInspectionSticker:inspectionStickerImage withExpirationDate:inspectionStickerExpirationDate atCityId:cityId withCarId:carId completion:^(NSError *error) {
            if (error) {
                uploadError = error;
            }
            dispatch_group_leave(carPhotoGroup);
        }];
    }

    //Notify
    dispatch_group_notify(carPhotoGroup, dispatch_get_main_queue(), ^{
        completion(uploadError);
    });
    
}

- (void)uploadCarPhotoWithCarId:(NSString*)carId photoType:(CarPhotoType)carPhotoType andCompletion:(CarPhotoUploaded)photoUploaded {
    
    NSString *keyPhoto = [NSString stringWithPhotoType:carPhotoType];
    NSData *image = self.userData[keyPhoto];
    
    NSDictionary *paramDict = @{@"photoData" : image};
    
    [[NetworkManager sharedInstance] postCarPhotoWithParams:paramDict andCarID:carId andCarType:keyPhoto uploadCompleteBlock:^(NSString *photoUrl, NSError *error) {
        photoUploaded(nil,photoUrl,error);
    }];
    
}

@end
