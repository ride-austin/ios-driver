//
//  UITextField+Valid.m
//  RideDriver
//
//  Created by Carlos Alcala on 7/15/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "UITextField+Valid.h"

#import "NSString+Ride.h"
#import "NSString+Valid.h"

@implementation UITextField (Valid)

-(BOOL)isEmpty {
    return [NSString isEmpty:self.text];
}

-(BOOL)isValidPassword{
    return [self.text isValidPassword];
}

-(BOOL)isValidConfirmationPassword:(UITextField *)confirmPassword{
    return [self.text isValidConfirmationPassword:confirmPassword.text];
}

-(BOOL)isValidEmail{
    return [self.text isValidEmail];
}

-(BOOL)isValidEmailBasic{
    return [self.text isValidEmailBasic];
}

-(BOOL)isValidPhone{
    return [self.text isValidPhoneSIN];
}

@end
