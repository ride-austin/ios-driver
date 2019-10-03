//
//  RADriverReachedRideEvent.h
//  RideDriver
//
//  Created by Marcos Alba on 4/5/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RARideEvent.h"

/*
{
    "eventType":"DRIVER_REACHED",
    "eventTimestamp":"<epoch time in miliseconds>",
    "rideID":"123123", //device time stamp
    
}
*/

@interface RADriverReachedRideEvent : RARideEvent

@end
