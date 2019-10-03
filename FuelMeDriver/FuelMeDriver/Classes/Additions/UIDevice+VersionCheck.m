//
//  UIDevice+VersionCheck.m
//  RideAustin.com
//
//  Created by Tyson Bunch on 9/23/13.
//  Copyright (c) 2013 FuelMe, Inc. All rights reserved.
//

#import "UIDevice+VersionCheck.h"

@implementation UIDevice (VersionCheck)

- (NSUInteger)systemMajorVersion {
    NSString *version = [self systemVersion];
    return (NSUInteger)[version doubleValue];
}

@end
