//
//  RAEventParameters.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 7/18/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "SurgeArea.h"

@interface RAEventParameters : RABaseDataModel

//Hand Shake
@property (nonatomic, copy, readonly) NSNumber *handshakeExpiration;

//Ride Request
@property (nonatomic, copy, readonly) NSNumber *acceptanceExpiration;
@property (nonatomic, copy, readonly) NSNumber *acknowledgeExpiration;

//Rider Location
@property (nonatomic, copy, readonly) NSNumber *latitude;
@property (nonatomic, copy, readonly) NSNumber *longitude;
@property (nonatomic, copy, readonly) NSDate *timestamp;

//Inactive Event
@property (nonatomic, copy, readonly) NSString *source;
@property (nonatomic, copy, readonly) NSString *message;
@property (nonatomic, copy, readonly) NSArray<NSString *> *disabled;

//Queue Event
@property (nonatomic, copy, readonly) NSString *areaQueueName;

//Ride Upgrade & Hand Shake
@property (nonatomic, copy, readonly) NSNumber *rideId;

//Surge Areas
@property (nonatomic) NSArray<SurgeArea *> *surgeAreas;

@end

@interface RAEventParameters (EventStubGenerator)
+(instancetype)parametersFromJSON:(NSDictionary *)json;
@end
