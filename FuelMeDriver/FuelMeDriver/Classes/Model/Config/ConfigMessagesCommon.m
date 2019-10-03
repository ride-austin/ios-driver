//
//  ConfigMessagesCommon.m
//  Ride
//
//  Created by Theodore Gonzalez on 2/8/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "ConfigMessagesCommon.h"

@implementation ConfigMessagesCommon

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"networkTimeoutMessage" : @"networkTimeoutMessage"
            };
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _networkTimeoutMessage = @"You appear to have a poor connection. Keep calm and try again later.";
    }
    return self;
}

@end
