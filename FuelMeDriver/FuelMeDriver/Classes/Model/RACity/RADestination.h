//
//  RADestination.h
//  Ride
//
//  Created by Theodore Gonzalez on 11/25/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface RADestination : MTLModel <MTLJSONSerializing>

@property (nonatomic) NSString *placeDescription;
@property (nonatomic) NSString *primaryAddress;

+ (instancetype)austinAirport;
- (NSDictionary *)userInfo;
- (BOOL)didMatchString:(NSString *)searchString;

@end
