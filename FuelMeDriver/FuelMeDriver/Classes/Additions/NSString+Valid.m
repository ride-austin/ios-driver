//
//  NSString+Valid.m
//  RideDriver
//
//  Created by Carlos Alcala on 7/15/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "NSString+Valid.h"

#import <SinchVerification/SinchVerification.h>

@implementation NSString (Valid)

//check for valid password
-(BOOL)isValidPassword {
    BOOL valid = YES;
    if (self.length < kMinPasswordLength) {
        valid = NO;
    }
    
    return valid;
}

-(BOOL)isValidConfirmationPassword:(NSString*)confirmPassword{
    BOOL valid = NO;
    if (self && [self isEqualToString:confirmPassword]) {
        valid = YES;
    }
    
    return valid;
}

// check for valid email
// email Validation http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/

-(BOOL)isValidEmail {
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = kStricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}

//check valid email from old code base
-(BOOL)isValidEmailBasic {
    static NSPredicate *emailTest = nil;
    if(!emailTest) {
        emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"];
    }
    return [emailTest evaluateWithObject:self];
}

// check for valid Phone Number

-(BOOL)isValidPhone {
    static NSPredicate *phoneTest = nil;
    NSString *phoneRegex = @"^((\\+)|(00))[0-9]{6,14}$";
    if(!phoneTest) {
        phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    }
    return [phoneTest evaluateWithObject:self];
}

-(BOOL)isValidPhoneSIN {
    // setup default region
    NSString* defaultRegion = [SINDeviceRegion currentCountryCode];
    NSError *parseError = nil;
    id<SINPhoneNumber> phoneNumber = [SINPhoneNumberUtil() parse:self
                                                   defaultRegion:defaultRegion
                                                           error:&parseError];
    
    DBLog(@"PARSE ERROR: %@", parseError);
    
    if (!phoneNumber){
        return NO;
    }
    
    return YES;
}


-(BOOL)isValidPhoneNumberLength{
    
    BOOL check=NO;
    if ([self getNumbersFromString].length>=8) {
        check=YES;
    }
    return check ;
}

-(NSString*)getNumbersFromString{
    NSArray* Array = [self componentsSeparatedByCharactersInSet:
                      [[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
    NSString* returnString = [Array componentsJoinedByString:@""];
    
    return (returnString);
    
}

@end
