//
//  DriverMappingTests.m
//  DriverMappingTests
//
//  Created by Theodore Gonzalez on 7/17/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RAEventDataModel.h"
#import "NSDictionary+JSON.h"
#import "SurgeArea.h"

@interface DriverMappingTests : XCTestCase

@end

@implementation DriverMappingTests

- (void)testGoOfflineDriverInactiveEvent {
    DriverEventType eventType = DriverInactive;
    NSString *fileName = [self fileNameForEventType:eventType];
    [self assertEventWithFileName:fileName type:eventType];
}

- (void)testHandShakeEvent {
    DriverEventType eventType = HandShake;
    NSString *fileName = [self fileNameForEventType:eventType];
    [self assertEventWithFileName:fileName type:eventType];
}

- (void)testRequestedEvent {
    DriverEventType eventType = RideRequested;
    NSString *fileName = [self fileNameForEventType:eventType];
    [self assertEventWithFileName:fileName type:eventType];
}

- (void)testRiderCommentUpdatedEvent {
    DriverEventType eventType = RiderCommentUpdated;
    NSString *fileName = [self fileNameForEventType:eventType];
    [self assertEventWithFileName:fileName type:eventType];
}

- (void)testRiderLocationUpdatedEvent {
    DriverEventType eventType = RiderLocationUpdated;
    NSString *fileName = [self fileNameForEventType:eventType];
    [self assertEventWithFileName:fileName type:eventType];
}

- (void)testRiderCancelledEvent {
    DriverEventType eventType = RiderCancelledRide;
    NSString *fileName = [self fileNameForEventType:eventType];
    [self assertEventWithFileName:fileName type:eventType];
}

- (void)testDriverCancelledEvent {
    DriverEventType eventType = DriverCancelledRide;
    NSString *fileName = [self fileNameForEventType:eventType];
    [self assertEventWithFileName:fileName type:eventType];
}

- (void)testEndLocationUpdatedEvent {
    DriverEventType eventType = RideDestinationUpdated;
    NSString *fileName = [self fileNameForEventType:eventType];
    [self assertEventWithFileName:fileName type:eventType];
}

- (void)testAdminCancelledEvent {
    DriverEventType eventType = AdminCancelledRide;
    NSString *fileName = [self fileNameForEventType:eventType];
    [self assertEventWithFileName:fileName type:eventType];
}

- (void)testSurgeAreaUpdateEvent {
    DriverEventType eventType = SurgeAreaChanged;
    NSString *fileName = [self fileNameForEventType:eventType];
    [self assertEventWithFileName:fileName type:eventType];
}

- (void)testCarCategoryChangeEventAdminEdit {
    DriverEventType eventType = CarCategoryChanged;
    NSString *fileName = @"CAR_CATEGORY_CHANGE_EVENT_ADMIN_EDIT";
    [self assertEventWithFileName:fileName type:eventType];
}

- (void)testCarCategoryChangeEventMissedRequest {
    DriverEventType eventType = CarCategoryChanged;
    NSString *fileName = @"CAR_CATEGORY_CHANGE_EVENT_MISSED_REQUEST";
    [self assertEventWithFileName:fileName type:eventType];
}

- (void)testRideStackedReassigned {
    DriverEventType eventType = RideStackedReassigned;
    NSString *fileName = [self fileNameForEventType:eventType];
    [self assertEventWithFileName:fileName type:eventType];
}

- (void)assertEventWithFileName:(NSString *)fileName type:(DriverEventType)eventType {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    id response = [NSDictionary jsonFromResourceName:fileName bundle:bundle error:nil];
    
    NSError *error = nil;
    RAEventDataModel *model = [MTLJSONAdapter modelOfClass:[RAEventDataModel class] fromJSONDictionary:response error:&error];
    XCTAssert(error == nil);
    [self assertModel:model basedOnEventType:eventType];
    
    NSDictionary *json = [MTLJSONAdapter JSONDictionaryFromModel:model error:&error];
    XCTAssert(error == nil);
    
    RAEventDataModel *model2 = [MTLJSONAdapter modelOfClass:[RAEventDataModel class] fromJSONDictionary:json error:&error];
    XCTAssert(error == nil);
    [self assertModel:model2 basedOnEventType:eventType];
}

- (void)assertModel:(RAEventDataModel *)model basedOnEventType:(DriverEventType)eventType {
    XCTAssert(model != nil);
    XCTAssert(model.type == eventType);
    switch (eventType) {
        case DriverInactive:
            [self assertGoOfflineDriverInactiveModel:model];
            break;
        case HandShake:
            [self assertHandShakeEvent:model];
            break;
        case RideRequested:
            [self assertRequestedEvent:model];
            break;
        case RiderCommentUpdated:
            [self assertRiderCommentUpdated:model];
            break;
        case RiderLocationUpdated:
            [self assertRiderLocationUpdatedEvent:model];
            break;
        case RiderCancelledRide:
            [self assertRiderCancelledEvent:model];
            break;
        case DriverCancelledRide:
            [self assertDriverCancelledEvent:model];
            break;
        case RideDestinationUpdated:
            [self assertEndLocationUpdatedEvent:model];
            break;
        case AdminCancelledRide:
            [self assertAdminCancelledEvent:model];
            break;
        case CustomMessage:
        case QueueEntering:
        case QueueUpdate:
        case QueueLeavingArea:
        case QueueLeavingInactive:
        case QueueLeavingInARide:
        case QueueLeavingPenalty:
            break;
        case SurgeAreaChanged:
            [self assertSurgeAreaUpdateEvent:model];
            break;
        case CarCategoryChanged:
            [self assertCarCategoryChangeEvent:model];
            break;
        case RideStackedReassigned:
            [self assertRideStackedReassignedEvent:model];
            break;
        case RatingUpdated:
        case RideUpgradeAccepted:
        case RideUpgradeRejected:
            break;
        case DriverAvailable:
        case DriverAssignedToRide:
        case DriverReachedRider:
        case DriverRiding:
        case DriverTypeUpdate:
        case RideActive:
        case RideCompleted:
        case NoAvailableDriverForRide:
        case InvalidEventType:
            break;
    }
}

- (void)assertGoOfflineDriverInactiveModel:(RAEventDataModel<RAInactiveEventProtocol>*)model {
    XCTAssert([model.reason isEqualToString:@"You have been marked as offline due to inactivity. \nPlease go online again for additional requests."]);
    XCTAssert(model.source == NoLocationUpdate);
    XCTAssert(model.modelID.floatValue == 3406025);
}

- (void)assertHandShakeEvent:(RAEventDataModel<RAHandShakeEventProtocol> *)model {
    XCTAssert(model.modelID.longLongValue == 341341);
    XCTAssert(model.rideId.longLongValue == 123);
    XCTAssert(model.remainingHandShakeExpiration > 0);
}

- (void)assertRequestedEvent:(RAEventDataModel *)model {
    XCTAssert(model.modelID.floatValue == 3413420);
    RARideAddressDataModel *start = model.ride.startAddress;
    XCTAssert([start.address isEqualToString:@"Jollyville Road, Austin, Texas"]);
    XCTAssert( start.latitude.doubleValue  == 30.418022);
    XCTAssert( start.longitude.doubleValue == -97.75052700000001);
}

- (void)assertRiderCommentUpdated:(RAEventDataModel *)model {
    XCTAssert(model.modelID.floatValue == 2421864);
    RARideDataModel *ride = model.ride;
    XCTAssert([ride.comment isEqualToString:@"A new comment."]);
}

- (void)assertRiderLocationUpdatedEvent:(RAEventDataModel<RARiderLocationUpdateProtocol> *)model {
    XCTAssert(model.modelID.floatValue == 3413477);
    XCTAssert(model.location.coordinate.latitude == 30.4181743);
    XCTAssert(model.location.coordinate.longitude == -97.7502108);
    XCTAssert(model.timeStamp.timeIntervalSince1970 * 1000 == 1500393271692);
}

- (void)assertRiderCancelledEvent:(RAEventDataModel *)model {
    XCTAssert( model.modelID.floatValue == 3413608);
    XCTAssert([model.ride.rider.firstName isEqualToString:@"RiderName"]);
    XCTAssert([model.ride.driverPayment isEqualToNumber:@(4)]);
}

- (void)assertDriverCancelledEvent:(RAEventDataModel *)model {
    XCTAssert( model.modelID.floatValue == 3414308);
    XCTAssert([model.ride.driverPayment isEqualToNumber:@(4)]);
}

- (void)assertEndLocationUpdatedEvent:(RAEventDataModel *)model {
    XCTAssert(model.modelID.floatValue == 3413745);
    RARideAddressDataModel *end = model.ride.endAddress;
    
    XCTAssert([end.address isEqualToString:@"Austin-Bergstrom International Airport"]);
    XCTAssert( end.latitude.doubleValue  == 30.2021489);
    XCTAssert( end.longitude.doubleValue == -97.66682900000001);
}

- (void)assertAdminCancelledEvent:(RAEventDataModel *)model {
    XCTAssert( model.modelID.floatValue == 3413608);
}

- (void)assertSurgeAreaUpdateEvent:(RAEventDataModel<RASurgeAreaEventProtocol> *)model {
    XCTAssert(model.modelID.floatValue == 3416709);

    SurgeArea *surgeArea = model.surgeAreasUpdated.firstObject;
    XCTAssert(surgeArea.modelID.integerValue == 510);
    XCTAssert([surgeArea.name isEqualToString:@"DOWNTOWN - EAST OF CONGRESS"]);
    
    XCTAssert([surgeArea.carCategoriesFactors[@"LUXURY"]  isEqualToNumber:@(2.5)]);
    XCTAssert([surgeArea.carCategoriesFactors[@"SUV"]     isEqualToNumber:@(2.5)]);
    XCTAssert([surgeArea.carCategoriesFactors[@"PREMIUM"] isEqualToNumber:@(2.5)]);
    
    XCTAssert(surgeArea.centerPoint.latitude  ==  30.270609);
    XCTAssert(surgeArea.centerPoint.longitude == -97.749071);
    
    XCTAssert(surgeArea.hasSurgeGeometry == YES);
    XCTAssert(surgeArea.boundary.count == 7);
    
    CLLocationCoordinate2D firstCoord = [surgeArea.boundary coordinateAtIndex:0];
    XCTAssert(firstCoord.latitude  ==  30.27380000000001);
    XCTAssert(firstCoord.longitude == -97.74070000000002);
}

- (void)assertCarCategoryChangeEvent:(RAEventDataModel <RACarCategoryChangedEventProtocol> *)model {
    switch (model.categoryChangeSource) {
        case AdminEdit:
            XCTAssert([model.modelID isEqualToNumber:@(110765214)]);
            XCTAssert(model.categoryChangeSource == AdminEdit);
            break;
        case MissedRequest:
            XCTAssert([model.modelID isEqualToNumber:@(110765215)]);
            XCTAssert(model.categoryChangeSource == MissedRequest);
            break;
        case Unknown:
            XCTFail(@"Unknown categoryChangeSource is not expected");
            break;
    }
}

- (void)assertRideStackedReassignedEvent:(RAEventDataModel *)model {
    XCTAssertEqualObjects(model.modelID, @(111383211));
    XCTAssertEqualObjects(model.ride.modelID, @(1288783));
}

- (NSString *)fileNameForEventType:(DriverEventType)eventType {
    switch (eventType) {
        case DriverInactive:            return @"GO_OFFLINE_DRIVER_INACTIVE_EVENT";
        case HandShake:                 return @"HANDSHAKE_EVENT";
        case RideRequested:             return @"REQUESTED_EVENT";
        case RiderCommentUpdated:       return @"RIDER_COMMENT_UPDATED_EVENT";
        case RiderLocationUpdated:      return @"RIDER_LOCATION_UPDATED_EVENT";
        case RiderCancelledRide:        return @"RIDER_CANCELLED_EVENT";
        case DriverCancelledRide:       return @"DRIVER_CANCELLED_EVENT";
        case RideDestinationUpdated:    return @"END_LOCATION_UPDATED_EVENT";
        case AdminCancelledRide:        return @"ADMIN_CANCELLED_EVENT";
        case CustomMessage:             return nil;
        case QueueEntering:             return nil;
        case QueueUpdate:               return nil;
        case QueueLeavingArea:          return nil;
        case QueueLeavingInactive:      return nil;
        case QueueLeavingInARide:       return nil;
        case QueueLeavingPenalty:       return nil;
        case SurgeAreaChanged:          return @"SURGE_AREA_UPDATES_EVENT";
        case CarCategoryChanged:        return nil; //two events are handled
        case RatingUpdated:             return nil;
        case RideUpgradeAccepted:       return nil;
        case RideUpgradeRejected:       return nil;
        case DriverAvailable:           return nil;
        case DriverAssignedToRide:      return nil;
        case DriverReachedRider:        return nil;
        case DriverRiding:              return nil;
        case RideActive:                return nil;
        case RideCompleted:             return nil;
        case NoAvailableDriverForRide:  return nil;
        case InvalidEventType:          return nil;
        case DriverTypeUpdate:          return nil;
        case RideStackedReassigned:     return @"RIDE_STACKED_REASSIGNED_EVENT";
    }
}

- (void)testCarTypes {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    id response = [NSDictionary jsonFromResourceName:@"DRIVERS_CAR_TYPES_200" bundle:bundle error:nil];
    NSError *error = nil;
    
    NSArray<RACarCategoryDataModel *> *carCategories = [MTLJSONAdapter modelsOfClass:RACarCategoryDataModel.class fromJSONArray:response error:&error];
    XCTAssert(error == nil);
    RACarCategoryDataModel *regularCar = carCategories.firstObject;
    XCTAssert([regularCar.carCategory isEqualToString:@"REGULAR"]);
    XCTAssert([regularCar.title isEqualToString:@"STANDARD"]);
    XCTAssert([regularCar.iconURL.absoluteString isEqualToString:@"https://media.rideaustin.com/icon/regular.png"]);
    XCTAssert(regularCar.shouldShowAreaQueue == YES);
}
@end
