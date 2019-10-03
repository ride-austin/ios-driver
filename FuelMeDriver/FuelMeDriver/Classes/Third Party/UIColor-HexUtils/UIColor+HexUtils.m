//
//  UIColor+HexUtils.m
//
//  Created by Carlos Alcala on 5/25/16.
//  Copyright © 2016 Carlos Alcala. All rights reserved.
//
//  The MIT License (MIT)
//  Copyright (c) 2013 Marius Landwehr marius.landwehr@gmail.com
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "UIColor+HexUtils.h"

@implementation UIColor (HexUtils)

+ (UIColor *)colorWithHexValue:(NSInteger)color alpha:(CGFloat)alpha {
    return [UIColor colorWithRed:((float)((color & 0xFF0000) >> 16)) / 255.0
                           green:((float)((color & 0xFF00) >> 8)) / 255.0
                            blue:((float)(color & 0xFF)) / 255.0 alpha:alpha];
}

+ (UIColor *)colorWithHexValue:(NSInteger)color {
    return [UIColor colorWithHexValue:color alpha:1.0];
}

+ (UIColor *)colorWithHex:(NSString *)hexString {
    return [UIColor colorWithHex:hexString alpha:1.0];
}

+ (UIColor *)colorWithHex:(NSString *)hexString alpha:(CGFloat)alpha {
    
    // empty string invalid
    if (hexString.length == 0) {
        return nil;
    }
    
    // remove dash
    if('#' == [hexString characterAtIndex:0]) {
        hexString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    }
    
    // valid Hex String lenghts
    NSArray *validHexStringLengths = @[@3, @4, @6, @8];
    NSNumber *hexStringLengthNumber = [NSNumber numberWithUnsignedInteger:hexString.length];
    if ([validHexStringLengths indexOfObject:hexStringLengthNumber] == NSNotFound) {
        return nil;
    }
    
    // Brutal and not-very elegant test for non hex-numeric characters
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^a-fA-F|0-9]" options:0 error:NULL];
    NSUInteger match = [regex numberOfMatchesInString:hexString options:NSMatchingReportCompletion range:NSMakeRange(0, [hexString length])];
    
    if (match != 0) {
        return nil;
    }
    
    //check for alpha value in Hex String
    if (4 == hexString.length || 8 == hexString.length) {
        NSString * alphaHex = [hexString substringWithRange:NSMakeRange(0, 8 == hexString.length ? 2 : 1)];
        if (1 == alphaHex.length) alphaHex = [NSString stringWithFormat:@"%@%@", alphaHex, alphaHex];
        hexString = [NSString stringWithFormat:@"%@", [hexString substringFromIndex:8 == hexString.length ? 2 : 1]];
        unsigned alpha_u = [[self class] hexStringToUnsigned:alphaHex];
        alpha = ((CGFloat) alpha_u) / 255.0;
    }
    
    // complete 3 character Hex Strings to 6 characters
    hexString = [hexString hexShortStringComplete];
    
    // scan hex value
    unsigned int hexValue = [UIColor hexStringToUnsigned:hexString];
    
    return [UIColor colorWithHexValue:hexValue alpha:alpha];
}

+ (unsigned)hexStringToUnsigned:(NSString *)hexValue {
    unsigned value = 0;
    
    NSScanner *scanner = [NSScanner scannerWithString:hexValue];
    [scanner scanHexInt:&value];
    
    
    
    return value;
}

+ (NSString *)hexValuesFromUIColor:(UIColor *)color {
    
    if (!color) {
        return nil;
    }
    
    if (color == [UIColor whiteColor]) {
        // Special case, as white doesn't fall into the RGB color space
        return @"FFFFFF";
    }
    
    CGFloat red;
    CGFloat blue;
    CGFloat green;
    CGFloat alpha;
    
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    int redDec = (int)(red * 255);
    int greenDec = (int)(green * 255);
    int blueDec = (int)(blue * 255);
    
    NSString *returnString = [NSString stringWithFormat:@"%02x%02x%02x", (unsigned int)redDec, (unsigned int)greenDec, (unsigned int)blueDec];
    
    return returnString;
    
}

@end

@implementation NSString (HexTransform)

- (NSString *)hexShortStringComplete {
    if(self.length == 3) {
        NSString * hexString = [NSString stringWithFormat:@"%1$c%1$c%2$c%2$c%3$c%3$c",
                                [self characterAtIndex:0],
                                [self characterAtIndex:1],
                                [self characterAtIndex:2]];
        return hexString;
    }
    
    return self;
}

@end