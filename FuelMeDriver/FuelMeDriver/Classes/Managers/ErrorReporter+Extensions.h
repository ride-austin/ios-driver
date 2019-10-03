//
//  ErrorReporter+Extensions.h
//  RideDriver
//
//  Created by Robert on 8/3/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "ErrorReporter.h"
#import "RARideDataModel.h"
#import "RideDriverEnums.h"

@interface ErrorReporter (Extensions)

+ (NSDictionary*)routeErrorWithRideRequest:(RARideDataModel*)ride;
+ (void)reportRequestReceived:(RARideDataModel *)incomingRide onInvalidDriverState:(DriverState)driverState currentRide:(RARideDataModel *)currentRide;

@end
