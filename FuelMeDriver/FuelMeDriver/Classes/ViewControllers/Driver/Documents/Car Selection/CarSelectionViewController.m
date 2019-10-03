//
//  CarSelectionViewController.m
//  RideDriver
//
//  Created by Abdul Rehman on 12/11/2016.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "CarSelectionViewController.h"

#import "CarPhotoUpdateMenuViewController.h"
#import "CarSelectionDataSource.h"
#import "CarSelectionHeader.h"
#import "DriverCarPhotoViewController.h"
#import "DriverInspectionStickerViewController.h"
#import "InsuranceDocumentViewController.h"
#import "NSString+Utils.h"
#import "RideDriverConstants.h"
#import "RideDriver-Swift.h"
#import "RAAlertManager.h"

static NSString * const kCarSelectionHeaderIdentifier = @"CarSelectionHeader";

@interface CarSelectionViewController () <CarSelectionDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tblCarSelection;
@property (weak, nonatomic) IBOutlet UIView *vAddCarContainer;
@property (nonatomic, strong) NSArray *menuArray;
@property (nonatomic, strong) NSMutableArray<Car*> *cars;
@property (nonatomic) CarSelectionDataSource *carSelectionDataSourceAndDelegate;

//required
@property (nonatomic, readonly, copy) ConfigRegistration *regConfig;
@property (nonatomic, readonly, copy) RACityDetail *cityDetail;
@property (nonatomic, readonly, copy) NSString *driverID;

@end

@implementation CarSelectionViewController

- (void)configureWithCityDetail:(RACityDetail *)cityDetail registeredCity:(RACity *)registeredCity andDriverID:(NSString *)driverID {
    _cityDetail = cityDetail;
    _driverID   = driverID;
    _regConfig  = [ConfigRegistration configWithCity:registeredCity andDetail:cityDetail];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [@"My Cars" localized];
    
    self.carSelectionDataSourceAndDelegate = [[CarSelectionDataSource alloc] initWithDelegate:self andCityDetail:self.cityDetail];
    
    [self.tblCarSelection registerNib:[UINib nibWithNibName:kCarSelectionHeaderIdentifier bundle:nil] forHeaderFooterViewReuseIdentifier:kCarSelectionHeaderIdentifier];
    self.tblCarSelection.dataSource = self.carSelectionDataSourceAndDelegate;
    self.tblCarSelection.delegate = self.carSelectionDataSourceAndDelegate;
    
    self.vAddCarContainer.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.2].CGColor;
    self.vAddCarContainer.layer.shadowRadius = 3.5;
    self.vAddCarContainer.layer.shadowOpacity = 0.5;
    self.vAddCarContainer.layer.shadowOffset = CGSizeMake(0,-1);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateCarList];
}

#pragma mark - Data Filling

- (void)updateCarList {
    [self showHUD];
    [[NetworkManager sharedInstance] getCarsOfDriverWithID:self.driverID andCompletionBlock:^(NSArray<Car *> *cars, NSError *error) {
        [self hideHUD];
        NSArray *carsNotRemoved = [cars filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(Car * _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            return evaluatedObject.isRemoved == NO;
        }]];
        if (!error) {
            self.carSelectionDataSourceAndDelegate.cars = carsNotRemoved;
            [self.tblCarSelection reloadData];
        }
    }];
}

#pragma mark - Car Selection Delegate

- (void)didSelectInsuranceOptionWithCar:(Car *)car {
    InsuranceDocumentViewController *insuranceDocumentViewController = (InsuranceDocumentViewController*)[self createViewControllerFromStoryboard:@"PersonalDocuments" withIdentifier:@"InsuranceDocumentViewController"];
    insuranceDocumentViewController.regConfig   = self.regConfig;
    insuranceDocumentViewController.selectedCar = car;
    [self.navigationController pushViewController:insuranceDocumentViewController animated:YES];
}

- (void)didSelectUpdateCarPhotoOptionWithCar:(Car *)car {
    CarPhotoUpdateMenuViewController *carPhotoUpdateViewController = (CarPhotoUpdateMenuViewController*)[self createViewControllerFromStoryboard:@"DriverCars" withIdentifier:@"CarPhotoUpdateMenuViewController"];
    carPhotoUpdateViewController.regConfig = self.regConfig;
    carPhotoUpdateViewController.carID = car.modelID.stringValue;
    [self.navigationController pushViewController:carPhotoUpdateViewController animated:YES];
}

- (void)didSelectInspectionStikerWithCar:(Car *)car {
    DriverInspectionStickerViewController *driverInspectionStrickerViewController = [[DriverInspectionStickerViewController alloc] initWithCar:car andRegConfig:self.regConfig];
    
    [self.navigationController pushViewController:driverInspectionStrickerViewController animated:YES];
}

- (void)didSelectCar:(Car *)car {
    if ([self shouldChangeCar]) {
        [self submitSelectedCar:car];
    }
}

- (void)submitSelectedCar:(Car *)car {
    if (self.userOwnsCarAndIsNotAdmin == NO) {
        return;
    }
    
    NSString *driverId = self.driverID;
    [self showHUD];
    [[NetworkManager sharedInstance] selectCarWithCarID:car.modelID.stringValue andDriverID:driverId andCompletionBlock:^(id object, NSError *error) {
        [self hideHUD];
        if (error) {
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive]];
        } else {
            //Update selected car and carCategories in current session
            for (Car *tmpCar in [RASessionManager shared].currentSession.driver.cars) {
                tmpCar.isSelected = [tmpCar.modelID isEqual:car.modelID];
            }
            [[RASessionManager shared] saveUserCarTypes:car.carCategories];
            [PersistenceManager saveSelectedCar:car];
            [[NSNotificationCenter defaultCenter] postNotificationName:kUserCarTypesHasBeenChangedNotification object:car.carCategories];
            [self updateCarList];
        }
    }];
}

- (BOOL)shouldChangeCar {
    switch ([DriverManager shared].driverState) {
        case OfflineDriverState:
            return YES;
        case AvailableDriverState:
        case InvalidDriverState:
            [RAAlertManager showErrorWithAlertItem:[@"Please go offline to change your car" localized] andOptions:nil];
            return NO;
        case AcceptingRequest:
        case OnTripDriverState:
        case GoingToPickUpDriverState:
        case ArrivingToPickUpDriverState:
            [RAAlertManager showErrorWithAlertItem:[@"You cannot change your car while on trip" localized] andOptions:nil];
            return NO;
    }
}

#pragma Prepare For Segue

- (IBAction)btnAddCarPressed:(UIButton *)sender {
    if (self.userOwnsCarAndIsNotAdmin == NO) {
        return;
    }
    NSMutableDictionary *dataDict = [NSMutableDictionary new];
    dataDict[@"cityDetail"] = self.cityDetail;
    DriverCarPhotoViewController *vc = [[DriverCarPhotoViewController alloc] initWithUserData:dataDict registrationConfig:self.regConfig carPhotoType:FrontPhoto];
    vc.regConfig = self.regConfig;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Unwind Segue

- (IBAction)unwindToCarSelectionViewController : (UIStoryboardSegue*)segue {
    //Note: unwind method
    // To move from Insurance to the principal view controller
}

- (BOOL)userOwnsCarAndIsNotAdmin {
    return [self.driverID isEqualToString:[RASessionManager shared].currentSession.driver.modelID.stringValue];
}

@end
