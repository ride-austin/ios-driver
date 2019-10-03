//
//  RatingViewController.m
//  RideDriver
//
//  Created by Roberto Abreu on 7/29/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RatingViewController.h"
#import "PersistenceManager.h"
#import "RARatingManager.h"
#import "RARideAPI.h"
#import "RideDriver-Swift.h"
#import "RideRate.h"

#define kMinHeight 250.0
#define kMaxHeight 305.0

@implementation RatingViewController

- (instancetype)initWithRideDataModel:(RARideDataModel *)rideDataModel completionBlock:(void (^)(void))completion {
    if (self = [super init]) {
        self.rideDataModel = rideDataModel;
        self.completion = completion;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.lblDriverEarning.text = [NSString stringWithFormat:@"$ %0.2f", [self.rideDataModel.driverPayment doubleValue]];
}

#pragma mark - IBActions

- (IBAction)ratingViewChanged:(HCSStarRatingView*)sender {
    BOOL shouldEnabledSubmitBtn = sender.value > 0;
    [self.btnSubmit setEnabled:shouldEnabledSubmitBtn];
    
    UIColor *btnSubmitColor = shouldEnabledSubmitBtn ? UIColor.barButtonEnabled : UIColor.barButtonDisabled;
    [self.btnSubmit setBackgroundColor:btnSubmitColor];
    
    [self.btnSubmit setEnabled:(sender.value > 0)];
    CGFloat height = sender.value > 0 ? kMaxHeight : kMinHeight;
    self.constraintHeightContainer.constant = height;
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)submitTapped:(id)sender {
    CGFloat rating = self.ratingView.value;
    NSString *rideId = [self.rideDataModel.modelID stringValue];
    
    if (self.submitTapped) {
        self.submitTapped();
    }
    
    __weak RatingViewController *weakSelf = self;
    [RARideAPI addRate:rating toRideWithId:rideId andCompletionBlock:^(NSError *error) {
        [PersistenceManager removeUnratedRide:weakSelf.rideDataModel];
        
        if (error) {
            RideRate *rideRate = [[RideRate alloc] initWithRideId:rideId andRate:rating];
            [RARatingManager addRideRatedToCache:rideRate];
        }
        
        if (weakSelf.completion) {
            weakSelf.completion();
        }
    }];
}

@end
