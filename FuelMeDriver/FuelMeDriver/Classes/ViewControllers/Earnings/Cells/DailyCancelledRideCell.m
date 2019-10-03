//
//  DailyCancelledRideCell.m
//  RideDriver
//
//  Created by Abdul Rehman on 18/08/2016.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "DailyCancelledRideCell.h"

#import "NSDate+Utils.h"
#import "NSNumber+Utils.h"

@implementation DailyCancelledRideCell

#pragma mark - Helper Functions

- (IBAction)contactUsAction:(UIButton *)sender {
    //callback delegate function
    [self.delegate sendEmailWithRide:self.currentRide];
}

- (IBAction)toggleAction:(UIButton *)sender {
    //execute block
    if (self.expandBlock != nil) {
        self.expandBlock();
    }
}

- (void)toggleExpand:(BOOL)expand {
    if (expand) {
        self.activeIcon.alpha = 0.0;
        self.activeIcon.hidden = NO;
        self.inactiveIcon.alpha = 0.0;
        self.inactiveIcon.hidden = YES;
        
        [UIView animateWithDuration:0.8 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.activeIcon.alpha = 1.0;
        } completion:^(BOOL done){
            
        }];
        
    } else {
        self.inactiveIcon.alpha = 0.0;
        self.inactiveIcon.hidden = NO;
        self.activeIcon.alpha = 0.0;
        self.activeIcon.hidden = YES;
        [UIView animateWithDuration:0.8 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.inactiveIcon.alpha = 1.0;
        } completion:^(BOOL done){
            
        }];
    }
}

- (void)configureCellWithRide:(RideFareDataModel*)ride {
    self.currentRide = ride;
    
    //setup header
    self.carLabel.text = [NSString stringWithFormat:@"%@ - %@", self.currentRide.requestedCarType.title, self.currentRide.car.fullDescription];
    self.timeLabel.text = [self.currentRide.cancelledOn reportTimeString];
    self.earningLabel.text = [self.currentRide.driverPayment currencyString];
    
    //setup start/end locations
    self.startTimeLabel.text = [self.currentRide.cancelledOn reportTimeString];
    self.startAddressLabel.text = [self.currentRide.start fullAddress];
    self.endTimeLabel.text = [self.currentRide.cancelledOn reportTimeString];
    self.endAddressLabel.text = [self.currentRide.end fullAddress];
    self.constraintHeightRideView.constant = ([self.currentRide.end fullAddress] == nil) ? 60.0 : 120.0;
    
    //setup earnings detail
    self.baseFareValue.text = [self.currentRide.subTotal currencyString];
    self.yourEarningValue.text = [self.currentRide.totalFare currencyString];
    
    //load map URL and show image
}

- (void)prepareForReuse {
    [super prepareForReuse];
    //cleanup the map URL and image
    self.mapURL = nil;
    self.mapImageView.image = nil;
    self.activeIcon.hidden = YES;
    self.inactiveIcon.hidden = NO;
    self.inactiveIcon.alpha = 1.0;
}

@end
