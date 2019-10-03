//
//  NSNumber+Utils.m
//  RideDriver
//
//  Created by Carlos Alcala on 7/20/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "NSNumber+Utils.h"

@implementation NSNumber (Utils)

- (NSString *)currencyString {
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setCurrencyCode:@"USD"];
    [formatter setNegativeFormat:@"-¤#,##0.00"];
    NSString* currency = [formatter stringFromNumber:self];

    //return '$ 10' with space (per design)
    return [currency stringByReplacingOccurrencesOfString:@"$" withString:@"$ "];
}

- (NSString *)trimZeros {

    NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setUsesGroupingSeparator:NO];
    [formatter setMaximumFractionDigits:2];
    [formatter setMinimumFractionDigits:0];
    
    return [formatter stringFromNumber:self];
}

- (NSString *)shortString {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
    [formatter setPositiveFormat:@"0.##"];
    return [formatter stringFromNumber:self];
}

- (NSString *)timeFormat {
    
    int totalSeconds = [self intValue];
    
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%02d:%02d",hours, minutes];
}

@end
