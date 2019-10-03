//
//  ConfigLiveLocation.h
//  Ride
//
//  Created by Theodore Gonzalez on 3/14/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface ConfigLiveLocation : MTLModel <MTLJSONSerializing>

@property (nonatomic, readonly) BOOL enabled;
@property (nonatomic, readonly) NSNumber *requiredAccuracy;
@property (nonatomic, readonly) NSNumber *expirationTime; // seconds

@end

@interface CLLocation (ValidLiveLocation)

- (BOOL)isValidLiveLocationBasedOnConfig:(ConfigLiveLocation *)config;

@end
