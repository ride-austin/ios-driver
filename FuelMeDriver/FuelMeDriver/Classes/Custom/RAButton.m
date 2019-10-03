//
//  RAButton.m
//  Ride
//
//  Created by Theodore Gonzalez on 12/14/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RAButton.h"

#import "RideDriver-Swift.h"

@implementation RAButton

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _enabledColor  = [UIColor azureBlue];
        _disabledColor = [UIColor bombayGray];
    }
    return self;
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    self.backgroundColor = enabled ? self.enabledColor : self.disabledColor;
}

@end
