//
//  QueueEvent.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 10/17/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "QueueEvent.h"

#import "ConfigurationManager.h"
#import "ErrorReporter.h"
#import "LocationService.h"
#import "NSString+Ride.h"

@implementation QueueEvent

+ (instancetype)eventWithType:(DriverEventType)eventType andAreaQueueName:(NSString *)areaQueueName {
    QueueEvent *event = [[self alloc] initWithEventType:eventType andAreaQueueName:areaQueueName];
    return event;
}

- (instancetype)initWithEventType:(DriverEventType)eventType andAreaQueueName:(NSString *)areaQueueName {
    self = [super init];
    if (self) {
        _areaQueueName = areaQueueName;
        _eventType = eventType;
    }
    return self;
}

- (NSString *)noRAqueueName {
    NSString *noRCityName = [self.areaQueueName stringByReplacingOccurrencesOfString:@"RideAustin" withString:@""];
    noRCityName = [noRCityName stringByReplacingOccurrencesOfString:[ConfigurationManager appName] withString:@""];
    return noRCityName;
}

- (NSString *)welcomeMessage {
    return [NSString stringWithFormat:@"Welcome to the %@ zone. ",self.areaQueueName];
}

- (NSString *)alertTitle {
    switch (self.eventType) {
        case QueueEntering:
        case QueueUpdate:
            return [NSString stringWithFormat:@"%@ Zone",self.areaQueueName];
        case QueueLeavingArea:
            return [NSString stringWithFormat:@"You left the %@ zone",self.noRAqueueName];
        case QueueLeavingInactive:
            return [NSString stringWithFormat:@"You have been removed from the %@ queue", self.noRAqueueName];
        default:
            return nil;
    }
}

- (NSString *)alertMessage {
    switch (self.eventType) {
        case QueueLeavingArea:
            return [NSString stringWithFormat:@"You have left the %@ zone and have been removed from the queue.",self.areaQueueName];
        case QueueLeavingInactive:
            return [NSString stringWithFormat:@"You have been removed from the %@ queue because you were offline", self.noRAqueueName];
        default:
            return nil;
    }
}

- (NSString *)description {   
    return [NSString stringWithFormat:@"Queue Event with areaName %@ for type %@ and location %@",self.areaQueueName,[NSString stringFromDriverEventType:self.eventType],[LocationService sharedService].myLocation];
}

@end
