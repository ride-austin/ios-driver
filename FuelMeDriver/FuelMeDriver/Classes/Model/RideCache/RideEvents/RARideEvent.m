//
//  RARideEvent.m
//  RideDriver
//
//  Created by Kitos on 6/9/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "RARideEvent.h"
#import "NSDate+Utils.h"
static NSString *const kRideEventJSONRideID = @"rideId";
static NSString *const kRideEventJSONEventType = @"eventType";
static NSString *const kRideEventJSONTimestamp = @"eventTimestamp";

@interface RARideEvent ()

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *timestamp;

@end

@implementation RARideEvent

- (instancetype)init {
    self = [super init];
    if (self) {
        self.event = [self.class eventType];
        self.date = [NSDate trueDate];
    }
    return self;
}

- (instancetype)initWithRideID:(NSString *)rideID {
    self = [super init];
    if (self) {
        self.event = [self.class eventType];
        self.rideID = rideID;
        self.date = [NSDate trueDate];
    }
    return self;
}

- (void)setDate:(NSDate *)date {
    _date = date;
    unsigned long long t3 = (unsigned long long)(date.timeIntervalSince1970)*1000;
    self.timestamp = [NSString stringWithFormat:@"%llu", t3];
}

@end

#pragma mark - RideEvent Protocol

@implementation RARideEvent (EventProtocol)

+ (NSString *)eventType {
    return @"UNKNOWN";
}

- (NSString *)hashString {
    return [NSString stringWithFormat:@"%@.%@.%@",self.rideID, self.event,self.timestamp];
}

- (NSDictionary *)jsonObject {
    NSString *rideID = self.rideID;
    if (!rideID) {
        rideID = @"unknownRideID";
    }
    NSString *event = self.event;
    NSString *timestamp = self.timestamp;
    if (!timestamp) {
        timestamp = @"0";
    }
    
    return @{
             kRideEventJSONRideID       :   rideID,
             kRideEventJSONEventType    :   event,
             kRideEventJSONTimestamp    :   timestamp
             };
}

@end

#pragma mark - Coding

static NSString *const kRideEventCoderRideID = @"kRideEventCoderRideID";
static NSString *const kRideEventCoderEventType = @"kRideEventCoderEventType";
static NSString *const kRideEventCoderTimestamp = @"kRideEventCoderTimestamp";

@implementation RARideEvent (Coding)

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.rideID = [coder decodeObjectForKey:kRideEventCoderRideID];
        self.event = [coder decodeObjectForKey:kRideEventCoderEventType];
        self.date = [coder decodeObjectForKey:kRideEventCoderTimestamp];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.rideID forKey:kRideEventCoderRideID];
    [coder encodeObject:self.event forKey:kRideEventCoderEventType];
    [coder encodeObject:self.date forKey:kRideEventCoderTimestamp];
}

@end
