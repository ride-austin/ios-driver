//
//  NSString+PhoneUtils.m
//  Ride
//
//  Created by Theodore Gonzalez on 11/2/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "NSString+PhoneUtils.h"
#import <MRCountryPicker/MRCountryPicker-Swift.h>

@implementation NSString (PhoneUtils)
-(NSString*)clearedPhoneNumber{
    NSString *phone = self;
    
    phone = [phone stringByReplacingOccurrencesOfString:@" " withString:@""];
    phone = [phone stringByReplacingOccurrencesOfString:@"(" withString:@""];
    phone = [phone stringByReplacingOccurrencesOfString:@")" withString:@""];
    phone = [phone stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    NSRange zerosRange = [phone rangeOfString:@"00"];
    
    if (zerosRange.location == 0) {
        phone = [phone stringByReplacingCharactersInRange:zerosRange withString:@"+"];
    }
    
    return phone;
    
}

-(NSString*)countryCode{
    NSString *countryCode = nil;
    
    NSString *phone = [self clearedPhoneNumber];
    
    NSBundle *mrCountryBundle = [NSBundle bundleForClass:[MRCountryPicker class]];
    NSString *countriesPath = [mrCountryBundle pathForResource:@"SwiftCountryPicker.bundle/Data/countryCodes" ofType:@"json"];
    NSData *countriesData = [NSData dataWithContentsOfFile:countriesPath];
    NSError *parseError = nil;
    NSArray *countriesArray = [NSJSONSerialization JSONObjectWithData:countriesData options:0 error:&parseError];
    
    NSUInteger i = 0;
    
    while (!countryCode && i<countriesArray.count) {
        NSDictionary *country = countriesArray[i];
        NSString *cc = country[@"dial_code"];
        if ([phone hasPrefix:cc]) {
            countryCode = cc;
        }
        
        i++;
    }
    
    return countryCode;
    
}

-(BOOL)hasCountryCode:(NSString*)countryCode{
    if (countryCode) {
        NSString *phone = [self clearedPhoneNumber];
        return [phone hasPrefix:countryCode];
    }
    else{
        return YES;
    }
}

@end
