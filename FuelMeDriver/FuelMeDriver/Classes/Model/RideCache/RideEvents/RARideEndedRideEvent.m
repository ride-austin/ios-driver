//
//  RARideEndedRideEvent.m
//  RideDriver
//
//  Created by Marcos Alba on 4/5/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RARideEndedRideEvent.h"

@implementation RARideEndedRideEvent

@end

#pragma mark - RideEvent Protocol

static NSString *const kRideEventJSONEndLatitude = @"endLocationLat";
static NSString *const kRideEventJSONEndLongitude = @"endLocationLong";
static NSString *const kRideEventJSONEndAddress = @"endAddress";
static NSString *const kRideEventJSONEndZip = @"endZipCode";

@implementation RARideEndedRideEvent (EventProtocol)

+ (NSString *)eventType {
    return @"END_RIDE";
}

- (NSString *)hashString {
    NSString *hash = super.hashString;
    return [hash stringByAppendingFormat:@".%f.%f.%@",self.latitude,self.longitude,self.zipCode];
}

- (NSDictionary *)jsonObject {
    NSMutableDictionary *md = [NSMutableDictionary dictionaryWithDictionary: super.jsonObject];
    
    NSString *address = self.address;
    if (!address) {
        address = @"";
    }
    NSString *zipCode = self.zipCode;
    if (!zipCode) {
        zipCode = @"";
    }
    
    md[kRideEventJSONEndLatitude] = [NSString stringWithFormat:@"%f", self.latitude];
    md[kRideEventJSONEndLongitude] = [NSString stringWithFormat:@"%f", self.longitude];
    md[kRideEventJSONEndAddress] = address;
    md[kRideEventJSONEndZip] = zipCode;
    
    return [NSDictionary dictionaryWithDictionary:md];
}

@end

#pragma mark - Coding

static NSString *const kRideEventCoderLatitude = @"kRideEventCoderLatitude";
static NSString *const kRideEventCoderLongitude = @"kRideEventCoderLongitude";
static NSString *const kRideEventCoderAddress = @"kRideEventCoderAddress";
static NSString *const kRideEventCoderZip = @"kRideEventCoderZip";

@implementation RARideEndedRideEvent (Coding)

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.latitude = [coder decodeDoubleForKey:kRideEventCoderLatitude];
        self.longitude = [coder decodeDoubleForKey:kRideEventCoderLongitude];
        self.address = [coder decodeObjectForKey:kRideEventCoderAddress];
        self.zipCode = [coder decodeObjectForKey:kRideEventCoderZip];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeDouble:self.latitude forKey:kRideEventCoderLatitude];
    [coder encodeDouble:self.longitude forKey:kRideEventCoderLongitude];
    [coder encodeObject:self.address forKey:kRideEventCoderAddress];
    [coder encodeObject:self.zipCode forKey:kRideEventCoderZip];
}

@end
