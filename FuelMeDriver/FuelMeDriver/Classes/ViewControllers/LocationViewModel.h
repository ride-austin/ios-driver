//
//  LocationViewModel.h
//  RideDriver
//
//  Created by Roberto Abreu on 6/15/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DriverManager.h"
#import "RAEventDataModel.h"
#import "RARideDataModel.h"

@interface LocationViewModel : NSObject

@property (nonatomic) RARideDataModel *rideDataModel;

- (NSString *)rideRequestCallKitNameFromEvent:(id<RARideRequestProtocol>)event;
- (NSString *)rideRequestNotificationBodyFromEvent:(id<RARideRequestProtocol>)event;
- (BOOL)shouldPresentRideRequestFromEvent:(id<RARideRequestProtocol>)event onDriverState:(DriverState)driverState;

#pragma mark - Ride
- (CLLocation *)destinationToShowBasedOnStateForCurrentRide;
- (BOOL)canShowDestination;

#pragma mark - Route
- (BOOL)canProceedToCreateRoute;
- (CLLocationCoordinate2D)startCoordinateForRouteOnDriverState:(DriverState)driverState;
- (CLLocationCoordinate2D)endCoordinateForRouteOnDriverState:(DriverState)driverState;

@end
