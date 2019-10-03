//
//  ConfigDriverMessages.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 1/18/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "ConfigDriverMessages.h"

@implementation ConfigDriverMessages

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"locationSettingsAlwaysPrompt":@"iOSLocationSettingsAlwaysPrompt"
            };
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.locationSettingsAlwaysPrompt = @"When online, please allow location access 'Always' to avoid unexpected issues";
    }
    return self;
}

@end
