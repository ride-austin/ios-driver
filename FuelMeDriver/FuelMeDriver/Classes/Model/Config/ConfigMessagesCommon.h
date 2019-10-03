//
//  ConfigMessagesCommon.h
//  Ride
//
//  Created by Theodore Gonzalez on 2/8/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface ConfigMessagesCommon : MTLModel <MTLJSONSerializing>

@property (nonatomic, readonly) NSString *networkTimeoutMessage;

@end
