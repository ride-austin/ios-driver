//
//  RAEventDataModel.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 6/4/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RAEventDataModel.h"

#import "NSDate+Utils.h"
#import "NSDictionary+JSON.h"
#import "RAEventParameters.h"

@interface RAEventDataModel()

@property (nonatomic, nullable, copy) RAEventParameters *parameters;

@end

@implementation RAEventDataModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{ @"eventType": @"eventType",
              @"ride"     : @"ride",
              @"nextRide" : @"nextRide",
              @"modelID"  : @"id",
              @"message"    : @"message",
              @"title"      : @"title",
              @"parameters" : @"parameters"
            };
}

#pragma mark - Transformers

+ (NSValueTransformer *)rideJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        return [MTLJSONAdapter modelOfClass:[RARideDataModel class] fromJSONDictionary:value error:error];
    } reverseBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        if ([value isKindOfClass:[RARideDataModel class]]) {
            NSDictionary *object = [MTLJSONAdapter JSONDictionaryFromModel:value error:error];
            return object;
        } else{
            return nil;
        }
    }];
}

+ (NSValueTransformer *)nextRideJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        return [MTLJSONAdapter modelOfClass:[RARideDataModel class] fromJSONDictionary:value error:error];
    } reverseBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        if ([value isKindOfClass:[RARideDataModel class]]) {
            NSDictionary *object = [MTLJSONAdapter JSONDictionaryFromModel:value error:error];
            return object;
        } else{
            return nil;
        }
    }];
}

+ (NSValueTransformer*)parametersJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        if (![value isKindOfClass:[NSString class]]) {
            return nil;
        }
        
        id params = [NSJSONSerialization JSONObjectWithData:[value dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:error];
        NSAssert(*error == nil, @"RAEventParameters failed with error: %@", *error);
        
        RAEventParameters *parameters;
        if ([params isKindOfClass:NSDictionary.class]) {
            parameters = [MTLJSONAdapter modelOfClass:RAEventParameters.class fromJSONDictionary:params error:error];
        }
        
        NSAssert(*error == nil, @"RAEventParameters failed with error: %@", *error);
        return parameters;
    } reverseBlock:^id(RAEventParameters *parameters, BOOL *success, NSError *__autoreleasing *error) {
        if ([parameters isKindOfClass:[RAEventParameters class]]) {
            NSDictionary *json = [MTLJSONAdapter JSONDictionaryFromModel:parameters error:error];
            if ([json isKindOfClass:[NSDictionary class]]) {
                NSData *dataRepresentation = [NSJSONSerialization dataWithJSONObject:json options:0 error:error];
                NSString *string = [[NSString alloc] initWithData:dataRepresentation encoding:NSUTF8StringEncoding];
                return string;
            }
            NSAssert(*error == nil, @"RAEventParameters reverseBlock failed with error: %@", *error);
        }
        
        return nil;
    }];
}

#pragma mark -

- (DriverEventType)type {
    
    NSDictionary<NSString *, NSNumber *> *events =
    @{
      @"HANDSHAKE"               : @(HandShake),
      @"REQUESTED"               : @(RideRequested),
      @"RIDER_LOCATION_UPDATED"  : @(RiderLocationUpdated),
      @"RIDER_CANCELLED"         : @(RiderCancelledRide),
      @"DRIVER_ASSIGNED"         : @(DriverAssignedToRide),
      @"DRIVER_CANCELLED"        : @(DriverCancelledRide),
      @"DRIVER_REACHED"          : @(DriverReachedRider),
      @"ACTIVE"                  : @(RideActive),
      @"NO_AVAILABLE_DRIVER"     : @(NoAvailableDriverForRide),
      @"COMPLETED"               : @(RideCompleted),
      @"ADMIN_CANCELLED"         : @(AdminCancelledRide),
      @"END_LOCATION_UPDATED"    : @(RideDestinationUpdated),
      @"AVAILABLE"               : @(DriverAvailable),
      @"RIDING"                  : @(DriverRiding),
      @"INACTIVE"                : @(DriverInactive),
      @"GO_OFFLINE"              : @(DriverInactive),
      @"CUSTOM_MESSAGE"          : @(CustomMessage),
      @"QUEUED_AREA_ENTERING"        : @(QueueEntering),
      @"QUEUED_AREA_UPDATE"          : @(QueueUpdate),
      @"QUEUED_AREA_LEAVING"         : @(QueueLeavingArea),
      @"QUEUED_AREA_LEAVING_INACTIVE": @(QueueLeavingInactive),
      @"QUEUED_AREA_LEAVING_RIDE"    : @(QueueLeavingInARide),
      @"QUEUED_AREA_LEAVING_PENALTY" : @(QueueLeavingPenalty),
      @"SURGE_AREA_UPDATES"      : @(SurgeAreaChanged),
      @"CAR_CATEGORY_CHANGE"     : @(CarCategoryChanged),
      @"DRIVER_TYPE_UPDATE"      : @(DriverTypeUpdate),
      @"RATING_UPDATED"          : @(RatingUpdated),
      @"RIDER_COMMENT_UPDATED"   : @(RiderCommentUpdated),
      @"RIDE_UPGRADE_ACCEPTED"   : @(RideUpgradeAccepted),
      @"RIDE_UPGRADE_DECLINED"   : @(RideUpgradeRejected),
      @"RIDE_STACKED_REASSIGNED" : @(RideStackedReassigned)
      };
    
    if (events[self.eventType]) {
        return events[self.eventType].integerValue;
    } else {
        NSAssert(events[self.eventType] != nil, @"EVENT %@ IS NOT SUPPORTED", self.eventType);
        return InvalidEventType;
    }
}

@end

#pragma mark - Protocols Adoptions

@implementation RAEventDataModel (RAHandShakeEventProtocol)

- (NSTimeInterval)remainingHandShakeExpiration {
    double expiration = self.parameters.handshakeExpiration.doubleValue;
    NSTimeInterval remaining = expiration / 1000 - [[NSDate trueDate] timeIntervalSince1970];
    return remaining;
}

- (NSNumber *)rideId {
    return self.parameters.rideId;
}


@end

@implementation RAEventDataModel (RARideRequestProtocol)

- (NSTimeInterval)remainingAcceptanceExpiration {
    NSParameterAssert(self.parameters.acceptanceExpiration);
    double expiration = self.parameters.acceptanceExpiration.doubleValue;
    NSTimeInterval remaining = expiration / 1000 - [[NSDate trueDate] timeIntervalSince1970];
    return remaining;
}

- (NSTimeInterval)remainingAcknowledgeExpiration {
    double expiration = self.parameters.acknowledgeExpiration.doubleValue;
    NSTimeInterval remaining = expiration / 1000 - [[NSDate trueDate] timeIntervalSince1970];
    return remaining;
}

- (BOOL)isStackedRide {
    return self.nextRide != nil;
}

@end

@implementation RAEventDataModel (RARiderLocationUpdateProtocol)

- (CLLocation *)location {
    return [[CLLocation alloc] initWithLatitude:self.parameters.latitude.doubleValue
                                      longitude:self.parameters.longitude.doubleValue];
}

- (NSDate *)timeStamp {
    return self.parameters.timestamp;
}

@end

@implementation RAEventDataModel (RAInactiveEventProtocol)

- (InactiveEventSource)source {
    NSString *source = self.parameters.source;
    if ([source isEqualToString:@"TERMS_NOT_ACCEPTED"]) {
        return TermsNotAccepted;
    } else if ([source isEqualToString:@"MISSED_RIDES"]) {
        return MissedRides;
    } else if ([source isEqualToString:@"DRIVER_INACTIVE"]) {
        return NoLocationUpdate;
    } else if ([source isEqualToString:@"CAR_TYPES_DEACTIVATE"]) {
        return CarTypesDeactivate;
    }
    return InactiveSourceUnknown;
}

- (NSString *)reason {
    return self.parameters.message;
}

@end

@implementation RAEventDataModel (RASurgeAreaEventProtocol)

- (NSArray<SurgeArea *> *)surgeAreasUpdated {
    return self.parameters.surgeAreas;
}

@end

@implementation RAEventDataModel (RAQueueEventProtocol)

- (NSString *)areaQueueName {
    return self.parameters.areaQueueName;
}

@end

@implementation RAEventDataModel (RAQueueEventPenaltyProtocol)

- (NSString *)areaQueueName {
    return self.parameters.areaQueueName;
}

- (NSString *)message {
    return self.parameters.message;
}

@end

@implementation RAEventDataModel (RARideUpgradeEventProtocol)

- (NSNumber *)rideId {
    return self.parameters.rideId;
}

@end

@implementation RAEventDataModel (RACarCategoryChangedEventProtocol)

- (CarCategoryChangeSource)categoryChangeSource {
    NSString *source = self.parameters.source;
    if ([source isEqualToString:@"ADMIN_EDIT"]) {
        return AdminEdit;
    } else if ([source isEqualToString:@"MISSED_REQUEST"]) {
        return MissedRequest;
    }
    return Unknown;
}

- (NSArray<NSString *> *)missedCategories {
    return self.parameters.disabled;
}

@end

@implementation RAEventDataModel (EventStubGenerator)

- (instancetype)initWithModelId:(NSNumber *)modelId
                     eventType:(NSString *)eventType
                          ride:(RARideDataModel *)ride
                parametersJSON:(NSDictionary *)parametersJSON {
    if (self = [super init]) {
        _modelID   = modelId;
        _eventType = eventType;
        _ride      = ride;
        _parameters = [RAEventParameters parametersFromJSON:parametersJSON];
    }
    return self;
}

#pragma mark - Test Objects

+ (instancetype)eventRequestedWithRide:(RARideDataModel *)ride modelId:(NSNumber *)modelId {
    return [[RAEventDataModel alloc] initWithModelId:modelId
                                           eventType:@"REQUESTED"
                                                ride:ride
                                      parametersJSON:nil];
}

+ (instancetype)eventEndLocationUpdatedWithRide:(RARideDataModel *)ride modelId:(NSNumber *)modelId {
    return [[RAEventDataModel alloc] initWithModelId:modelId
                                           eventType:@"END_LOCATION_UPDATED"
                                                ride:ride
                                      parametersJSON:nil];
}

+ (instancetype)eventRiderCommentUpdatedWithRide:(RARideDataModel *)ride modelId:(NSNumber *)modelId {
    return [[RAEventDataModel alloc] initWithModelId:modelId
                                           eventType:@"RIDER_COMMENT_UPDATED"
                                                ride:ride
                                      parametersJSON:nil];
}

+ (instancetype)eventUpgradeRequestAcceptedWithRide:(RARideDataModel *)ride modelId:(NSNumber *)modelId {
    return [[RAEventDataModel alloc] initWithModelId:modelId
                                           eventType:@"RIDE_UPGRADE_ACCEPTED"
                                                ride:ride
                                      parametersJSON:nil];
}

+ (instancetype)eventUpgradeRequestDeclineByRiderWithRide:(RARideDataModel *)ride modelId:(NSNumber *)modelId {
    NSDictionary *json = @{@"rideId" : ride.modelID};
    return [[RAEventDataModel alloc] initWithModelId:modelId
                                           eventType:@"RIDE_UPGRADE_DECLINED"
                                                ride:ride
                                      parametersJSON:json];
}

+ (instancetype)eventUpdateRiderLocationWithLatitude:(NSNumber *)latitude longitude:(NSNumber *)longitude modelId:(NSNumber *)modelId {
    NSDictionary *json = @{@"lat": latitude,
                           @"lng": longitude};
    return [[RAEventDataModel alloc] initWithModelId:modelId
                                           eventType:@"RIDER_LOCATION_UPDATED"
                                                ride:nil
                                      parametersJSON:json];
}

+ (instancetype)eventAdminCancelledRide:(RARideDataModel *)ride modelId:(NSNumber *)modelId {
    return [[RAEventDataModel alloc] initWithModelId:modelId
                                           eventType:@"ADMIN_CANCELLED"
                                                ride:ride
                                      parametersJSON:nil];
}

- (void)incrementModelId {
    _modelID = @(_modelID.longLongValue + 1);
}

- (void)updateRideAcceptanceWithLaunchDate:(NSDate *)launchDate {
    NSNumber *acceptance  = @((launchDate.timeIntervalSince1970 + 10) * 1000);
    NSNumber *acknowledge = @((launchDate.timeIntervalSince1970 + 5)  * 1000);
    
    NSDictionary *json = @{ @"acceptanceExpiration"  : acceptance,
                            @"acknowledgeExpiration" : acknowledge };
    self.parameters = [RAEventParameters parametersFromJSON:json];
}

@end
