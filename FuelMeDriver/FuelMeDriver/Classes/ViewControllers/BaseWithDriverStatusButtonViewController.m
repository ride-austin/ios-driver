//
//  BaseWithDriverStatusButtonViewController.m
//  RideDriver
//
//  Created by Marcos Alba on 7/6/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "BaseWithDriverStatusButtonViewController.h"

@interface BaseWithDriverStatusButtonViewController ()

@property (nonatomic, strong) DriverStatusButton *driverStatusButton;

@end

@implementation BaseWithDriverStatusButtonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat buttonHeight = 27;
    CGFloat buttonWidth = [UIScreen mainScreen].bounds.size.width <= 320 ? 100 : 120;
    self.driverStatusButton = [[DriverStatusButton alloc] initWithFrame: CGRectMake(0, 0, buttonWidth, buttonHeight)];
    [self.driverStatusButton addTarget:self action:@selector(driverStatusButtonHasBeenPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self placeDriverStatusButtonInNavigationBar];
}

- (void)placeDriverStatusButtonInNavigationBar {
    self.navigationItem.titleView = self.driverStatusButton;
}

- (void)driverStatusButtonHasBeenPressed:(DriverStatusButton *)sender {
    DBLog(@"driverStatusButtonHasBeenPressed should be implemented by subclasses")
}

@end
