//
//  SplashViewController.h
//  FuelMe
//
//  Created by Tyson Bunch on 9/19/12.
//  Copyright (c) 2012 FuelMe, Inc. All rights reserved.
//

#import "BaseViewController.h"
#import "FlatButton.h"
#import "RACity.h"

@interface SplashViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@property (weak, nonatomic) IBOutlet UIView *authContainerView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UILabel* version;
@property (weak, nonatomic) IBOutlet UIImageView *splashImage;
@property (weak, nonatomic) IBOutlet UIImageView *ivWhiteLogo;
@property (weak, nonatomic) IBOutlet FlatButton *loginButton;
@property (weak, nonatomic) IBOutlet FlatButton *createButton;

@end
