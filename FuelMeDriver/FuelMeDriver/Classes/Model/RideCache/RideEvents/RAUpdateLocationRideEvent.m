//
//  RAUpdateLocationRideEvent.m
//  RideDriver
//
//  Created by Marcos Alba on 4/5/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RAUpdateLocationRideEvent.h"

@implementation RAUpdateLocationRideEvent

- (instancetype)initWithRideID:(NSString *)rideID {
    self = [super initWithRideID:rideID];
    
    if (self) {
        self.heading = 0;
        self.speed = -1;
        self.course = 0;
        self.latitude = 91;
        self.longitude = 181;
    }
    
    return self;
}

@end

#pragma mark - RideEvent Protocol

static NSString *const kRideEventJSONLatitude = @"latitude";
static NSString *const kRideEventJSONLongitude = @"longitude";
static NSString *const kRideEventJSONSpeed = @"speed";
static NSString *const kRideEventJSONHeading = @"heading";
static NSString *const kRideEventJSONCourse = @"course";

@implementation RAUpdateLocationRideEvent (EventProtocol)

+ (NSString *)eventType {
    return @"UPDATE_LOCATION";
}

- (NSString *)hashString {
    NSString *hash = super.hashString;
    return [hash stringByAppendingFormat:@".%f.%f",self.latitude,self.longitude];
}

- (NSDictionary *)jsonObject {
    NSMutableDictionary *md = [NSMutableDictionary dictionaryWithDictionary: super.jsonObject];
    
    md[kRideEventJSONLatitude] = [NSString stringWithFormat:@"%f", self.latitude];
    md[kRideEventJSONLongitude] = [NSString stringWithFormat:@"%f", self.longitude];
    md[kRideEventJSONSpeed] = [NSString stringWithFormat:@"%f", self.speed];
    md[kRideEventJSONHeading] = [NSString stringWithFormat:@"%f", self.heading];
    md[kRideEventJSONCourse] = [NSString stringWithFormat:@"%f", self.course];

    return [NSDictionary dictionaryWithDictionary:md];
}

@end

#pragma mark - Coding

static NSString *const kRideEventCoderLatitude = @"kRideEventCoderLatitude";
static NSString *const kRideEventCoderLongitude = @"kRideEventCoderLongitude";
static NSString *const kRideEventCoderSpeed = @"kRideEventCoderSpeed";
static NSString *const kRideEventCoderHeading = @"kRideEventCoderHeading";
static NSString *const kRideEventCoderCourse = @"kRideEventCoderCourse";

@implementation RAUpdateLocationRideEvent (Coding)

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.latitude = [coder decodeDoubleForKey:kRideEventCoderLatitude];
        self.longitude = [coder decodeDoubleForKey:kRideEventCoderLongitude];
        self.speed = [coder decodeDoubleForKey:kRideEventCoderSpeed];
        self.heading = [coder decodeDoubleForKey:kRideEventCoderHeading];
        self.course = [coder decodeDoubleForKey:kRideEventCoderCourse];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeDouble:self.latitude forKey:kRideEventCoderLatitude];
    [coder encodeDouble:self.longitude forKey:kRideEventCoderLongitude];
    [coder encodeDouble:self.speed forKey:kRideEventCoderSpeed];
    [coder encodeDouble:self.heading forKey:kRideEventCoderHeading];
    [coder encodeDouble:self.course forKey:kRideEventCoderCourse];    
}

@end
