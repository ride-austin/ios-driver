//
//  RARideEndedRideEvent.h
//  RideDriver
//
//  Created by Marcos Alba on 4/5/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RARideEvent.h"

/*
 
{
    "eventType":"END_RIDE",
    "eventTimestamp":"<epoch time in miliseconds>", //device time stamp
    "rideID":"123123",
    "endLocationLat":"30.259097325987234",
    "endLocationLong":"-97.74615994855786",
    "endAddress":"Texas",
    "endZipCode":"Texas",
}

*/

@interface RARideEndedRideEvent : RARideEvent

@property (nonatomic) CLLocationDegrees latitude;
@property (nonatomic) CLLocationDegrees longitude;
@property (nonatomic) NSString *address;
@property (nonatomic) NSString *zipCode;

@end
