//
//  ConfigDriverMessages.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 1/18/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface ConfigDriverMessages : MTLModel <MTLJSONSerializing>

@property (nonatomic) NSString *locationSettingsAlwaysPrompt;

@end
