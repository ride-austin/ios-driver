//
//  RAUpdateLocationRideEvent.h
//  RideDriver
//
//  Created by Marcos Alba on 4/5/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RARideEvent.h"

/*
{
    "eventType":"UPDATE_LOCATION",
    "eventTimestamp":"<epoch time in miliseconds>", //device time stamp
    "rideID":"123123",
    "latitude":"30.259097325987234",
    "longitude":"-97.74615994855786",
    "speed":"123123.123",
    "heading":"123123.123",
    "course":"123123.123"
}
*/

@interface RAUpdateLocationRideEvent : RARideEvent

@property (nonatomic) CLLocationDegrees latitude;
@property (nonatomic) CLLocationDegrees longitude;
@property (nonatomic) CLLocationSpeed speed;
@property (nonatomic) CLLocationDirection heading;
@property (nonatomic) CLLocationDirection course;

@end
