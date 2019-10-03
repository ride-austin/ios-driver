//
//  RequestViewController.h
//  RideDriver
//
//  Created by Roberto Abreu on 31/10/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseWithDriverStatusButtonViewController.h"
#import "RAEventDataModel.h"

#import <GoogleMaps/GoogleMaps.h>

@protocol RideRequestDelegate <NSObject>

- (void)didTimerFinishForEvent:(id<RARideRequestProtocol>)event;
- (void)didTapDeclineButtonForEvent:(id<RARideRequestProtocol>)event;
- (void)didTapAcceptButtonForEvent:(id<RARideRequestProtocol>)event;
- (void)didTapOnlineButtonForEvent:(id<RARideRequestProtocol>)event;

@end

@interface RideRequestViewController : BaseWithDriverStatusButtonViewController

#pragma mark - IBOutlets
@property (weak, nonatomic) IBOutlet GMSMapView *googleMapView;

//Information Request
@property (weak, nonatomic) IBOutlet UIView *vInformationRequestContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblETA;
@property (weak, nonatomic) IBOutlet UILabel *lblPrimaryAddress;
@property (weak, nonatomic) IBOutlet UILabel *lblRiderRating;
@property (weak, nonatomic) IBOutlet UILabel *lblRiderUsername;
@property (weak, nonatomic) IBOutlet UIImageView *imgRider;

@property (weak, nonatomic) IBOutlet UILabel *lblSecondsAvailable;
@property (weak, nonatomic) IBOutlet UIButton *btnAccept;
@property (weak, nonatomic) IBOutlet UIView *vLineSeparator;

//Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTopLblETA;

#pragma mark - Properties
@property (strong, nonatomic) id <RARideRequestProtocol> event;
@property (strong, nonatomic) UIWindow *internalWindow;
@property (strong,nonatomic) GMSMarker *tmpCarIcon;
@property (weak, nonatomic) id<RideRequestDelegate> rideRequestDelegate;


#pragma mark - Method

- (void)showAnimated:(BOOL)animated;
- (void)dismissRequestView;
- (void)dismissRequestViewForRideRequestWithId:(NSString *)rideId;

@end
