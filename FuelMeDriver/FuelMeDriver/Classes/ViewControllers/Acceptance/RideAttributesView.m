//
//  RideAttributesView.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 4/2/18.
//  Copyright © 2018 FuelMe LLC. All rights reserved.
//

#import "RideAttributesView.h"
#import "RARideDataModel.h"
@interface RideAttributesView()

@end

@implementation RideAttributesView

- (instancetype)initWithFrame:(CGRect)frame andRide:(RARideDataModel *)ride {
    if (self = [super initWithFrame:frame]) {
        UIView *v = [[NSBundle mainBundle] loadNibNamed:[self nibNameForRide:ride] owner:self options:nil].firstObject;
        v.frame = self.bounds;
        v.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:v];
        [self updateForRide:ride];
    }
    return self;
}

- (void)updateForRide:(RARideDataModel *)ride {
    self.lbCarCategory.accessibilityLabel = @"lblCarType";
    self.lbSurgeFactor.accessibilityLabel = @"lblPriority";
    
    NSNumberFormatter *twoDecimalPlaceFormatter = [NSNumberFormatter new]; //1.90
    twoDecimalPlaceFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    twoDecimalPlaceFormatter.roundingIncrement = @(0.01);
    self.lbSurgeFactor.text = [NSString stringWithFormat:@"%@X", [twoDecimalPlaceFormatter stringFromNumber:ride.surgeFactor]];

    if ([ride containsDriverType:DriverTypeDirectConnect]) {
        if (ride.hasSurgeFactor) {
            self.lbCarCategory.text = [NSString stringWithFormat:@"DIRECT CONNECT:\n%@", ride.requestedCarType.title];
        } else {
            self.lbCarCategory.text = [NSString stringWithFormat:@"DIRECT CONNECT: %@", ride.requestedCarType.title];
        }
    } else {
        self.lbCarCategory.text = ride.requestedCarType.title;
    }
}

- (NSString *)nibNameForRide:(RARideDataModel *)ride {
    BOOL hasSurgeFactor = ride.hasSurgeFactor;
    BOOL isDC = [ride containsDriverType:DriverTypeDirectConnect];
    if (hasSurgeFactor && isDC) {
        return @"RideAttributesDCSurgeView";
    }
    
    if (hasSurgeFactor && !isDC) {
        return @"RideAttributesRegularSurgeView";
    }
    
    if (!hasSurgeFactor && isDC) {
        return @"RideAttributesDCView";
    }
    
    if (!hasSurgeFactor && !isDC) {
        return @"RideAttributesRegularView";
    }
    return @"RideAttributesRegularView";
}

@end
