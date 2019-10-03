//
//  RAContact.m
//  RideDriver
//
//  Created by Kitos on 5/11/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "RAContact.h"

@interface NSString (ContactLabel)

- (NSString*)clear;

@end

#pragma mark - Contact Label

@implementation NSString (ContactLabel)

- (NSString *)clear {
    NSString *s = self;
    s = [s stringByReplacingOccurrencesOfString:@"_" withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@"<" withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@">" withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@"$" withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@"¡" withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@"!" withString:@""];
    return s;
}

@end

@implementation RALabeledValue

- (void)setLabel:(NSString *)label {
    _label = [label clear];
}

@end

@implementation RAContact

@end
