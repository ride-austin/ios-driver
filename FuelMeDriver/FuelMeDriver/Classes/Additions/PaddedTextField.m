//
//  PaddedTextField.m
//  Ride
//
//  Created by Abdul Rehman on 16/05/2016.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "PaddedTextField.h"

@implementation PaddedTextField

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 10, 10);
}

// text position
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 10, 10);
}
@end
