//
//  ConfigReferFriend.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 11/2/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface ConfigReferFriend : MTLModel <MTLJSONSerializing>

@property (nonatomic) NSString *body;
@property (nonatomic) NSString *header;
@property (nonatomic) NSString *menuTitle;
@property (nonatomic) BOOL isSMSEnabled;
@property (nonatomic) BOOL isEmailEnabled;

- (BOOL)enabled;

@end
