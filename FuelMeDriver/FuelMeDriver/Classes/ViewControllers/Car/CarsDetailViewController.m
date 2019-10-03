//
//  CarsDetailViewController.m
//  RideDriver
//
//  Created by Adriano Alencar on 19/05/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "CarsDetailViewController.h"

@interface CarsDetailViewController()

@property (weak, nonatomic) IBOutlet UITextField *license;

@end

@implementation CarsDetailViewController

- (void)saveCar {
    [self.view endEditing:YES];
    if ([self.license isEmpty]) {
        UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@"RideAustin"
                                                      message:@"License is invalid/required" delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles: nil];
        [alert show];
    } else  {
        self.car.license = self.license.text;
        RideUser.Car = self.car;
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:self.car forKey:@"car"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kCarAdded" object:userInfo];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)setDetails:(NSString*)year make:(NSString*)make model:(NSString*)model color:(NSString*)color image:(UIImage*)image {
    self.car = [[Car alloc] init];
    self.car.year = year;
    self.car.model = model;
    self.car.make = make;
    self.car.color = color;
//    self.car.fuelType = @"REGULAR";
//    self.car.favorite = [NSNumber numberWithBool:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.title = @"LICENSE PLATE";
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 25, 20)];
    self.license.leftView = paddingView;
    self.license.leftViewMode = UITextFieldViewModeAlways;
    
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"DONE" style:UIBarButtonItemStylePlain target:self action:@selector(saveCar)];
    [self.navigationItem setRightBarButtonItem:doneButton];
}

@end
