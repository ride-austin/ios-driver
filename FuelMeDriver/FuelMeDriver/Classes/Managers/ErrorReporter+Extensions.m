//
//  ErrorReporter+Extensions.m
//  RideDriver
//
//  Created by Robert on 8/3/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "ErrorReporter+Extensions.h"

#import "NSString+Ride.h"
#import "RARideAddressDataModel.h"

@implementation ErrorReporter (Extensions)

+ (NSDictionary *)routeErrorWithRideRequest:(RARideDataModel *)ride {
    NSDictionary *errorUserInfo = nil;
    if (!ride) {
        errorUserInfo = @{@"issue":@"self.rideRequest is null"};
    } else if (!ride.startAddress) {
        errorUserInfo = @{@"issue":@"self.rideRequest.from is null"};
    } else if (!ride.endAddress) {
        errorUserInfo = @{@"issue":@"self.rideRequest.to is null"};
    }
    return errorUserInfo;
}

+ (void)reportRequestReceived:(RARideDataModel *)incomingRide onInvalidDriverState:(DriverState)driverState currentRide:(RARideDataModel *)currentRide {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    NSString *domain = [NSString stringWithFormat:@"WATCHRideRequestReceivedWhile%@:", [NSString driverStateToString:driverState]];

    dict[@"currentRide"] = currentRide.modelID;
    dict[@"newRide"]     = incomingRide.modelID;
    
    NSError *error = [NSError errorWithDomain:domain code:WATCHrequestReceivedWhileOnTrip userInfo:dict];
    [ErrorReporter recordError:error withDomainName:WATCHrequestReceivedWhileOnTrip andCustomName:domain];
}

@end
