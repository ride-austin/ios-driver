//
//  ConfigCancellationFeedback.h
//  Ride
//
//  Created by Theodore Gonzalez on 3/28/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface ConfigCancellationFeedback : MTLModel <MTLJSONSerializing>

@property (nonatomic) BOOL enabled;

@end
