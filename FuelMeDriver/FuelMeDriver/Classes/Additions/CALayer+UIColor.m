//
//  CALayer+UIColor.m
//  Ride
//
//  Created by Tyson Bunch on 5/13/16.
//  Copyright © 2016 FuelMe, Inc. All rights reserved.
//

#import "CALayer+UIColor.h"

@implementation CALayer (UIColor)

- (void)setBorderUIColor:(UIColor*)color {
    self.borderColor = color.CGColor;
}

- (UIColor*)borderUIColor {
    return [UIColor colorWithCGColor:self.borderColor];
}

@end
