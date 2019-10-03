//
//  ConfigWomanOnly.h
//  Ride
//
//  Created by Theodore Gonzalez on 11/26/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface ConfigWomanOnly : MTLModel <MTLJSONSerializing>

@property (nonatomic) BOOL isEnabled;

@end
