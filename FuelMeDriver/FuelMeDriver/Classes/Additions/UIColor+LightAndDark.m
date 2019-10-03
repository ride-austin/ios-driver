//
//  UIColor+LightAndDark.m
//  RideAustin.com
//
//  Created by Tyson Bunch on 9/19/12.
//  Copyright (c) 2012 FuelMe, Inc. All rights reserved.
//

#import "UIColor+LightAndDark.h"

@implementation UIColor (LightAndDark)

- (UIColor*)lighterColor
{
    CGFloat h, s, b, a;
    if ([self getHue:&h saturation:&s brightness:&b alpha:&a])
        return [UIColor colorWithHue:h saturation:s brightness:MIN(b * 1.5, 1.0) alpha:a];
    return nil;
}

- (UIColor*)darkerColor
{
    CGFloat h, s, b, a;
    if ([self getHue:&h saturation:&s brightness:&b alpha:&a])
        return [UIColor colorWithHue:h
                          saturation:s
                          brightness:b * 0.8
                            alpha:a];
    return nil;
}

@end
