//
//  CarsDetailViewController.m
//  RideAustin.com
//
//  Created by Tyson Bunch on 10/11/12.
//  Copyright (c) 2012 FuelMe, Inc. All rights reserved.
//

#import "CarsDetailViewController.h"

#import "FormValidator.h"
#import "NSString+Utils.h"
#import "RideUser.h"
#import "RAAlertManager.h"

@interface CarsDetailViewController ()
@property (nonatomic) FormValidator *validator;
@end

@implementation CarsDetailViewController

- (void)saveCar {
    [self.view endEditing:YES];
    if ([self.validator isValid:self.license.text]) {
        self.car.license = self.license.text;
        
        // store the car info to the global variable, will save it to server after the driver data is available.
        RideUser.Car = self.car;
        
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:self.car forKey:@"car"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kCarAdded" object:userInfo];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [RAAlertManager showErrorWithAlertItem:[@"Please enter your license plate" localized] andOptions:[RAAlertOption optionWithState:StateActive]];
    }
}

- (id)initWithYear:(NSString*)year make:(NSString*)make model:(NSString*)model color:(NSString*)color image:(UIImage*)image {
    self = [super init];
    if (self) {
        self.car = [[Car alloc] init];
        self.car.year = year;
        self.car.model = model;
        self.car.make = make;
        self.car.color = color;
 
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.title = [@"LICENSE PLATE" localized];
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 25, 20)];
    self.license.leftView = paddingView;
    self.license.leftViewMode = UITextFieldViewModeAlways;
    [self configureValidator];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:[@"DONE" localized] style:UIBarButtonItemStylePlain target:self action:@selector(saveCar)];
    [self.navigationItem setRightBarButtonItem:doneButton];
}

- (void)configureValidator {
    self.validator = [FormValidator validatorWithType:TFTypeLicensePlate];
    self.license.delegate = self.validator;
}

@end
