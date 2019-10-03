//
//  RARideCache.m
//  RideDriver
//
//  Created by Kitos on 6/9/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "RARideCache.h"

#import "RARideEndedRideEvent.h"

static NSString *const kRideCacheJSONEvents = @"events";

static NSString *const kRideCacheCoderRideID = @"kRideCacheCoderRideID";
static NSString *const kRideCacheCoderEvents = @"kRideCacheCoderEvents";
static NSString *const kRideCacheCoderReachedPickup = @"kRideCacheCoderReachedPickup";
static NSString *const kRideCacheCoderTripStarted = @"kRideCacheCoderTripStarted";
static NSString *const kRideCacheCoderCancelled = @"kRideCacheCoderCancelled";
static NSString *const kRideCacheCoderCompleted = @"kRideCacheCoderCompleted";

@interface RARideCache()<NSCoding>

@property (nonatomic, strong) NSString *rideID;
@property (nonatomic, strong, readwrite) NSDictionary <NSString*, RARideEvent*> *events;

@end

@implementation RARideCache

+ (RARideCache *)rideCacheForRideID:(NSString *)rideID {
    return [[RARideCache alloc] initWithRideID:rideID];
}

- (instancetype)initWithRideID:(NSString *)rideID {
    if (self = [super init]) {
        _rideID = rideID;
    }
    return self;
}

- (BOOL)hasData {
    return (self.events.count > 0);
}

- (void)addRideEvent:(RARideEvent *)rideEvent {
    if (rideEvent && [rideEvent.rideID isEqualToString:self.rideID]) {
        if (self.events) {
            NSMutableDictionary *md = [NSMutableDictionary dictionaryWithDictionary:self.events];
            md[rideEvent.hashString] = rideEvent;
            self.events = [NSDictionary dictionaryWithDictionary:md];
        } else {
            self.events = @{rideEvent.hashString : rideEvent};
        }
    }
}

- (NSDictionary*)jsonObject {
    if (self.events.count > 0) {
        NSMutableArray *ma = [NSMutableArray arrayWithCapacity:self.events.count];
        
        NSArray *events = self.events.allValues;
        events = [events sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            RARideEvent *ev1 = (RARideEvent*)obj1;
            RARideEvent *ev2 = (RARideEvent*)obj2;
            
            return [ev1.date compare:ev2.date];
        }];
        
        BOOL reachedEndEvent = NO; //Used to discard newer events after end ride event.
        NSUInteger i = 0;
        while (!reachedEndEvent && i<events.count) {
            RARideEvent *rideEvent = events[i];
            NSDictionary *jsonDict = [rideEvent jsonObject];
            if (jsonDict) {
                [ma addObject:jsonDict];
            }
            reachedEndEvent = [rideEvent isKindOfClass:[RARideEndedRideEvent class]];
            i++;
        }
        
        if (ma.count > 0) {
            return @{kRideCacheJSONEvents : ma};
        }
    }
    
    return nil;
}

- (void)cleanCache {
    self.events = nil;
}

- (DriverState)driverState {
    if (self.wasCompleted) {
        return AvailableDriverState;
    } else if (self.wasTripStarted) {
        return OnTripDriverState;
    } else if (self.wasReachedPickup) {
        return ArrivingToPickUpDriverState;
    } else {
        return GoingToPickUpDriverState;
    }
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.rideID = [coder decodeObjectForKey:kRideCacheCoderRideID];
        self.events = [coder decodeObjectForKey:kRideCacheCoderEvents];
        self.reachedPickup = [coder decodeBoolForKey:kRideCacheCoderReachedPickup];
        self.tripStarted = [coder decodeBoolForKey:kRideCacheCoderTripStarted];
        self.completed = [coder decodeBoolForKey:kRideCacheCoderCompleted];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.rideID forKey:kRideCacheCoderRideID];
    [coder encodeObject:self.events forKey:kRideCacheCoderEvents];
    [coder encodeBool:self.reachedPickup forKey:kRideCacheCoderReachedPickup];
    [coder encodeBool:self.tripStarted forKey:kRideCacheCoderTripStarted];
    [coder encodeBool:self.completed forKey:kRideCacheCoderCompleted];
}

@end



