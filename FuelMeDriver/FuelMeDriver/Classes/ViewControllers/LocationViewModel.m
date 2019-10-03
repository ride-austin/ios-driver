//
//  LocationViewModel.m
//  RideDriver
//
//  Created by Roberto Abreu on 6/15/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "LocationViewModel.h"

#import "ErrorReporter+Extensions.h"
#import "LocationService.h"
#import "NSString+Utils.h"

@implementation LocationViewModel

#pragma mark - Ride Request

- (NSString *)rideRequestCallKitNameFromEvent:(id<RARideRequestProtocol>)event {
    RARideDataModel *ride = event.isStackedRide ? event.nextRide : event.ride;
    return [NSString stringWithFormat:[@"%@ needs %@ ride" localized], ride.rider.firstName, ride.requestedCarType.title];
}

- (NSString *)rideRequestNotificationBodyFromEvent:(id<RARideRequestProtocol>)event {
    RARideDataModel *ride = event.isStackedRide ? event.nextRide : event.ride;
    NSString *femaleIdentifier = [ride containsDriverType:DriverTypeFemaleDriver] ? @"♀ | " : @"";
    NSString *priorityMultiplier = ride.hasSurgeFactor ? [NSString stringWithFormat:@"| PF: %.02fX ", [ride.surgeFactor doubleValue]] : @"";
    return [NSString stringWithFormat:@"%@ETA %@ %@| %@", femaleIdentifier, ride.eta, priorityMultiplier, ride.startAddress.address];
}

- (BOOL)shouldPresentRideRequestFromEvent:(id<RARideRequestProtocol>)event onDriverState:(DriverState)driverState {
    switch (driverState) {
        case InvalidDriverState:
        case AvailableDriverState:
            return YES;
        case AcceptingRequest:
        case OfflineDriverState:
            [ErrorReporter reportRequestReceived:event.ride onInvalidDriverState:driverState currentRide:event.ride];
            return YES;
        case GoingToPickUpDriverState:
        case ArrivingToPickUpDriverState:
            [ErrorReporter reportRequestReceived:event.ride onInvalidDriverState:driverState currentRide:event.ride];
            return NO;
        case OnTripDriverState:
            if (event.isStackedRide) {
                return YES;
            }
            [ErrorReporter reportRequestReceived:event.ride onInvalidDriverState:driverState currentRide:event.ride];
            return NO;
    }
}

#pragma mark - Ride

- (CLLocation *)destinationToShowBasedOnStateForCurrentRide {
    switch ([DriverManager shared].driverState) {
        case AcceptingRequest:
        case GoingToPickUpDriverState:
            return self.rideDataModel.startAddress.location;
            
        case ArrivingToPickUpDriverState:
            return self.rideDataModel.endAddress.location;
            
        case OnTripDriverState:
            return self.rideDataModel.endAddress.location;
            
        case InvalidDriverState:
        case OfflineDriverState:
        case AvailableDriverState:
            return nil;
    }
}

- (BOOL)canShowDestination {
    switch ([DriverManager shared].driverState) {
        case AcceptingRequest:
        case InvalidDriverState:
        case OfflineDriverState:
        case AvailableDriverState:
        case GoingToPickUpDriverState:
            return NO;
        case ArrivingToPickUpDriverState:
        case OnTripDriverState:
            return YES;
    }
}

#pragma mark - Route

- (BOOL)canProceedToCreateRoute {
    DriverState driverState = [DriverManager shared].driverState;
    BOOL canCreateRouteWithFromLocation = self.rideDataModel && self.rideDataModel.startAddress;
    BOOL canCreateRouteWithToLocation = self.rideDataModel.endAddress.isValid && (driverState == ArrivingToPickUpDriverState || driverState == OnTripDriverState);
    
    NSDictionary *errorUserInfo = nil;
    if ((errorUserInfo = [ErrorReporter routeErrorWithRideRequest:self.rideDataModel])) {
        [ErrorReporter recordErrorDomainName:WATCHDrawRouteFailed withUserInfo:errorUserInfo];
    }
    
    return canCreateRouteWithFromLocation && (driverState == GoingToPickUpDriverState || canCreateRouteWithToLocation);
}

- (CLLocationCoordinate2D)startCoordinateForRouteOnDriverState:(DriverState)driverState {
    CLLocationCoordinate2D coordinateDriver = [LocationService sharedService].myLocation.coordinate;
    if (self.canProceedToCreateRoute) {
        switch (driverState) {
            case GoingToPickUpDriverState:
            case OnTripDriverState:
            case ArrivingToPickUpDriverState:
                return coordinateDriver;
            default:
                break;
        }
    }
    return kCLLocationCoordinate2DInvalid;
}

- (CLLocationCoordinate2D)endCoordinateForRouteOnDriverState:(DriverState)driverState {
    if (self.canProceedToCreateRoute) {
        switch (driverState) {
            case GoingToPickUpDriverState:
                return self.rideDataModel.startAddress.coordinate;
                
            case ArrivingToPickUpDriverState:
            case OnTripDriverState:
                return self.rideDataModel.endAddress.coordinate;

            default:
                break;
        }
    }
    return kCLLocationCoordinate2DInvalid;
}

@end
