//
//  UITextField+Valid.h
//  RideDriver
//
//  Created by Carlos Alcala on 7/15/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (Valid)

-(BOOL)isEmpty;
-(BOOL)isValidPassword;
-(BOOL)isValidConfirmationPassword:(UITextField *)confirmPassword;
-(BOOL)isValidEmail;
-(BOOL)isValidEmailBasic;
-(BOOL)isValidPhone;

@end
