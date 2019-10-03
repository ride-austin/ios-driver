//
//  RACity.h
//  Ride
//
//  Created by Carlos Alcala on 11/19/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RACoordinate.h"

#import <Mantle/Mantle.h>

typedef enum : NSUInteger {
    Austin = 0,
    Houston = 1,
} CityType;

typedef enum : NSUInteger {
    Foreground = 0,
    Background = 1,
    SecondaryText = 2,
    SecondaryBack = 3,
    Border = 4,
} CityColorType;

@interface RACity : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSNumber *cityID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) RACoordinate *cityCenter;

- (NSString *)appName;
- (NSString*)displayName;

- (CityType)cityType;

- (NSDictionary<NSString *, NSNumber *> *)requestParameter;
- (NSString *)requestParameterString;

@end
