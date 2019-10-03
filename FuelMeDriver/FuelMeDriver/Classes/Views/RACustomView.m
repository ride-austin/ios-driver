//
//  RACustomView.m
//  Ride
//
//  Created by Theodore Gonzalez on 12/9/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RACustomView.h"

#import "NSObject+className.h"

@implementation RACustomView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        UIView *v = [[NSBundle mainBundle] loadNibNamed:[self className] owner:self options:nil].firstObject;
        v.frame = self.bounds;
        v.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:v];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIView *v = [[NSBundle mainBundle] loadNibNamed:[self className] owner:self options:nil].firstObject;
        v.frame = self.bounds;
        v.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:v];
    }
    return self;
}

@end
