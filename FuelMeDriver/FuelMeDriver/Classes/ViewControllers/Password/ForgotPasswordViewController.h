//
//  ForgotPasswordViewController.h
//  Ride
//
//  Created by Tyson Bunch on 5/19/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "BaseViewController.h"

@class PaddedTextField;

@interface ForgotPasswordViewController : BaseViewController

@property(nonatomic, strong) IBOutlet PaddedTextField* emailTextField;

- (IBAction)doForgotPassword:(id)sender;

@end
