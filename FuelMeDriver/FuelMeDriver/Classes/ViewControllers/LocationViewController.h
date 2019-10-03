//
//  LocationViewController.h
//  RideAustin
//
//  Created by Tyson Bunch on 9/19/12.
//  Copyright (c) 2012 FuelMe, Inc. All rights reserved.
//

#import "ActionView.h"
#import "BaseWithDriverStatusButtonViewController.h"
#import "NSString+Ride.h"
#import "QueueViewController.h"
#import "RARideDataModel.h"
#import "SurgeAreaManager.h"
#import "UITextField+Utils.h"

#import "HCSStarRatingView.h"

typedef void(^SynchronizeClientBlock)(void);

@interface LocationViewController : BaseWithDriverStatusButtonViewController

NS_ASSUME_NONNULL_BEGIN

@property (weak, nonatomic) id<QueueUpdateDelegate> queueEventsDelegate;

@property (weak, nonatomic) IBOutlet GMSMapView *googleMapView;

//ActionView
@property (weak, nonatomic) IBOutlet ActionView *actionView;

//ActionButton reference
@property (weak, nonatomic) UIButton *statusButton;

//Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintDestinationTop;

- (void)initializeSurgeAreaManagerWithCompletion:(void(^)(void))completion;

#pragma mark - Terms & Conditions
- (void)askConfirmationToReadNewTermsAndConditionsWithMessage:(NSString*)message;
- (void)showNewTermsAndConditionIfNeeded;

#pragma mark- AUTO SWIPE MANAGER
- (void)autoSwipeManager;
- (void)didStartTripFromAlerts;
- (void)didEndTripFromLocalNotification;
- (void)checkIfDriverHasStartedTripWithoutSlidingButton;


#pragma mark - Local Notification Functions
- (void)showAlertOfflineForMissedRidesWithMessage:(NSString * _Nullable)message;

NS_ASSUME_NONNULL_END

@end
