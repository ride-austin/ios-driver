//
//  AppDelegate+NetworkStub.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 5/23/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "AppDelegate+NetworkStub.h"
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <OHHTTPStubs/OHHTTPStubsResponse+JSON.h>
#import <OHHTTPStubs/NSURLRequest+HTTPBodyTesting.h>
#import "OHHTTPStubs+Factory.h"
#import "TestManager.h"
#import "RideUser.h"
#import "PersistenceManager.h"
#import "EventStubModel.h"
#import "URLFactory.h"
#import "DriverRideEarnings.h"
#import "ConfigGlobal.h"
#import "RideDriver-Swift.h"
#import "ConfigurationManager.h"
#import "CLLocationManagerMock.h"
#import "LocationService.h"
#import "RASessionManager.h"
//#import <SWHttpTrafficRecorder/SWHttpTrafficRecorder.h>

@interface AppDelegate (Private)

- (void)initializeUITest;
- (void)registerDefaultStubsForCity:(NSUInteger)city withStubbingAuth:(BOOL)stubbingAuth;
- (void)loginStub;
- (void)logoutStub;
- (void)surgeAreaEmpty;
- (void)driverByIdStub;
- (void)currentActiveDriverOfflineStub;
- (void)goOnlineStub;
- (void)goOfflineStub;
//- (void)getActiveDriversEmptyStub;
- (void)getActiveDriversStub;
- (void)sendDriverLocationStub;
- (void)newTermNotAcceptedStub;
- (void)queuesStub;
- (void)configCityDetailStub;
- (void)goOnlineNotAcceptedTermStub;
- (void)driverTermsStub;
- (void)driverAcceptTermsStub;
- (void)driversCarTypesStub;
- (void)declineRideStub;
- (void)cancelRideStub;
- (void)requestUpgradeStub;
- (void)cancelUpgradeStub;
- (void)activeDriverRidingStub;
- (void)currentRideWithUpgradeRequestedStub;
- (void)setupDefaultLocationManager;
- (void)driverTypesStub;

@end

@interface AppDelegate (Earnings)
- (void)presentEarningsStub;
@end

@interface AppDelegate (SupportTopicsAPIStubs)
- (void)supportTopicsStubs;
@end

@interface AppDelegate (EventStubGenerator)
- (void)createEventStubsFromArguments:(NSArray<NSString *>*)arguments;
@end

@implementation AppDelegate (NetworkStub)

- (void)setupAutomatedTestEnvironment {
    AutomatedTestType type = [TestManager testType];
    switch (type) {
        case ATTNoAuth:{
            NSTimeInterval delay = 0;
            NSArray<NSString*> *args = [NSProcessInfo processInfo].arguments;
            NSUInteger delayIndex = [args indexOfObject:@"--delay"];
            if (delayIndex != NSNotFound && args.count > (delayIndex+1)) {
                NSString *delayArg = args[delayIndex+1];
                delay = delayArg.doubleValue;
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[RASessionManager shared] clearCurrentSession];
            });
        }
            break;
        case ATTNoNetwork:{
            NSTimeInterval timeout = -1;
            NSArray<NSString*> *args = [NSProcessInfo processInfo].arguments;
            NSUInteger toIndex = [args indexOfObject:@"--timeout"];
            if (toIndex != NSNotFound && args.count > (toIndex+1)) {
                NSString *to = args[toIndex+1];
                timeout = to.doubleValue;
            }
            
            //TODO: Simulate Network in NetworkManager
            /*[[RANetworkManager sharedManager] simulateNetworkStatus:RASimNetUnreachableStatus];
            if (timeout > 0) {
                [[RANetworkManager sharedManager] performSelector:@selector(disableNetworkStatusSimualation) withObject:nil afterDelay:timeout];
            }*/
        }
            break;
        case ATTSkipLogin:
        case ATTNoTest:
            break;
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
- (void)installNetworkStubsIfNeeded {
    [self installRecorder];
    NSArray<NSString*>* arguments = [NSProcessInfo processInfo].arguments;
    if ([arguments containsObject:@"STUB_NETWORK"]) {
        [OHHTTPStubs removeAllStubs];
        
        NSUInteger city = 0;
        NSUInteger cityIndex = [arguments indexOfObject:@"--city"];
        if (cityIndex != NSNotFound && arguments.count > (cityIndex+1)) {
            NSString *cityArg = arguments[cityIndex+1];
            city = cityArg.integerValue;
        }
        
        BOOL stubAuth = ![arguments containsObject:@"--realAuth"];
        
        [self initializeUITest];
        [self registerDefaultStubsForCity:city withStubbingAuth:stubAuth];
        [self createEventStubsFromArguments:arguments];

        [arguments enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj hasPrefix:@"MAP"]) {
                NSString *networkStubMappingPath = [[NSBundle mainBundle] pathForResource:@"NetworkStubMapping" ofType:@"plist"];
                NSDictionary *networkStubMapping = [NSDictionary dictionaryWithContentsOfFile:networkStubMappingPath];
                
                NSAssert(networkStubMapping, @"NetworkStubMapping should not be nil");
                NSAssert([[networkStubMapping allKeys] containsObject:obj], @"Network Stub Mapping doesn't contain Map");
                
                NSArray <NSString*>* methodMapping = [networkStubMapping objectForKey:obj];
                for (NSString *methodString in methodMapping) {
                    SEL selector = NSSelectorFromString(methodString);
                    NSAssert([self respondsToSelector:selector], @"%@ is not found in Appdelegate+NetworkStub", methodString);
                    [self performSelector:selector];
                }
            }
        }];
    }
}
/**
 *  recorded data is found in
 *  ~/Library/Developer/CoreSimulator/Devices/<check most recent device>/data/Containers/Data/Application/<most recent application>/Library/Caches
 */
- (void)installRecorder {
    //    NSArray *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //    NSString *docs = [documentPath objectAtIndex:0];
    //    NSString *path = [docs stringByAppendingPathComponent:@"yourdirectory"];
    //    [[SWHttpTrafficRecorder sharedRecorder] startRecording];
}
#pragma clang diagnostic pop
@end

@implementation AppDelegate (Private)

- (void)initializeUITest {
    [PersistenceManager removePendingRideRate];
}

- (void)registerDefaultStubsForCity:(NSUInteger)city withStubbingAuth:(BOOL)stubbingAuth {
    if (stubbingAuth) {
        [self loginStub];
        [self currentDriverStub];
    }
    [self logoutStub];
    [self getActiveDriversStub];
    [self currentActiveDriverOfflineStub];
    [self goOnlineStub];
    [self goOfflineStub];
    [self sendDriverLocationStub];
    [self surgeAreaEmpty];
    [self configGlobalStub];
    [self queuesStub];
    [self driverStub];
    [self configCityDetailStub];
    [self driverTermsStub];
    [self driverAcceptTermsStub];
    [self driversCarTypesStub];
    [self presentEarningsStub];
    [self supportTopicsStubs];
    [self declineRideStub];
    [self receivedRideStub];
    [self acceptRideRequestStub];
    [self sendArrivedStub];
    [self sendStartTripStub];
    [self getRideByIDStub];
    [self sendEndTripStub];
    [self sendRatingStub];
    [self cancelRideStub];
    [self requestUpgradeStub];
    [self cancelUpgradeStub];
    [self driverTypesStub];
    [self earningMapStub];
}

- (void)loginStub {
    [OHHTTPStubs addStubWithRequestPath:kPathLogin matchingHttpMethod:@"POST" responseHandler:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        OHHTTPStubsResponse *response = [OHHTTPStubs handlerResponseWithStatusCode:200 andFileName:@"LOGIN_SUCCESS"](request);
        response.httpHeaders = @{@"uuid" : @"991", @"content-type":@"application/json"};
        return response;
    }];
}

- (void)currentDriverStub {
    [OHHTTPStubs addStubWithGETRequestPath:kPathDriversCurrent statusCode:200 andResponseFileName:@"CURRENT_DRIVER_200"];
}

- (void)logoutStub {
    [OHHTTPStubs addStubWithPOSTRequestPath:kPathLogout statusCode:200 andResponseString:@""];
}

- (void)surgeAreaEmpty {
    [OHHTTPStubs addStubWithGETRequestPath:kPathSurgeAreas statusCode:200 andResponseFileName:@"SURGE_AREA_EMPTY"];
}

- (void)driverByIdStub {
    [OHHTTPStubs addStubWithGETRequestPath:[NSString stringWithFormat:kPathDriversSpecific,@"2187"] statusCode:200 andResponseFileName:@"CURRENT_DRIVER_NOT_ACCEPTED_TERM"];
}

- (void)currentActiveDriverOfflineStub {
    [OHHTTPStubs addStubWithGETRequestPath:kPathActiveDriverCurrent statusCode:204 andResponseFileName:@""];
}

- (void)goOnlineStub{
    [OHHTTPStubs addStubWithPOSTRequestPath:kPathActiveDriver statusCode:200 andResponseString:@""];
}

- (void)goOnlineNotAcceptedTermStub {
    [OHHTTPStubs addStubWithPOSTRequestPath:kPathActiveDriver responseHandler:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        if (agreedToLegalTerms) {
            return [OHHTTPStubs handlerResponseWithStatusCode:200 andResponseString:@""](request);
        } else {
            return [OHHTTPStubs handlerResponseWithStatusCode:412 andResponseString:@"In order to go online you should read and accept new Driver terms and conditions"](request);
        }
    }];
}

- (void)goOfflineStub {
    [OHHTTPStubs addStubWithDELETERequestPath:kPathActiveDriver statusCode:200 andResponseString:@""];
}

- (void)getActiveDriversEmptyStub {
    [OHHTTPStubs addStubWithGETRequestPath:kPathActiveDriver statusCode:200 andResponseFileName:@"ACTIVE_DRIVER_EMPTY"];
}

-(void)getActiveDriversStub{
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        NSString *normalizeRequestPath = [request.URL.path stringByReplacingOccurrencesOfString:@"/rest/" withString:@""];
        return [normalizeRequestPath hasPrefix:kPathActiveDriver];
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"ACDR_200" ofType:@"json"];
        NSAssert(path, @"Not file found with fileName : ACDR_200.json");
        return [OHHTTPStubsResponse responseWithFileAtPath:path statusCode:200 headers:@{@"content-type":@"application/json"}];
    }];
}

- (void)activeDriverRidingStub {
    [OHHTTPStubs addStubWithGETRequestPath:kPathActiveDriverCurrent statusCode:200 andResponseFileName:@"ACTIVE_DRIVER_RIDING"];
}

- (void)sendDriverLocationStub {
    [OHHTTPStubs addStubWithPUTRequestPath:kPathActiveDriver statusCode:200 andResponseString:@""];
}

static BOOL agreedToLegalTerms;
- (void)newTermNotAcceptedStub {
    [OHHTTPStubs addStubWithGETRequestPath:kPathDriversCurrent responseHandler:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"CURRENT_DRIVER_200" ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:path];
        NSMutableDictionary *driverDict = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil]];
        driverDict[@"agreedToLegalTerms"] = [NSNumber numberWithBool:agreedToLegalTerms];
        return [OHHTTPStubsResponse responseWithJSONObject:driverDict statusCode:200 headers:nil];
    }];
}

- (void)loadConfigGlobalWithFileName:(NSString*)configGlobalName {
    NSString *path = [[NSBundle mainBundle] pathForResource:configGlobalName ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:path];
    NSError *error;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&error];
    ConfigGlobal *configGlobal = [MTLJSONAdapter modelOfClass:[ConfigGlobal class] fromJSONDictionary:jsonDict error:&error];
    [PersistenceManager saveConfigGlobal:configGlobal];
}

- (void)configGlobalStub {
    [self loadConfigGlobalWithFileName:@"CONFIG_GLOBAL_200"];
    [OHHTTPStubs addStubWithGETRequestPath:kPathConfigsDriverGlobal statusCode:200 andResponseFileName:@"CONFIG_GLOBAL_200"];
}

- (void)queuesStub{
    [OHHTTPStubs addStubWithGETRequestPath:kPathQueues statusCode:200 andResponseFileName:@"QUEUES_SUCCESS"];
}

- (void)driverStub{
    NSString *path = [NSString stringWithFormat:kPathDriversSpecific,@"2187"];
    [OHHTTPStubs addStubWithGETRequestPath:path statusCode:200 andResponseFileName:@"CURRENT_DRIVER_200"];
}

- (void)configCityDetailStub {
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        NSString *normalizeRequestPath = [request.URL.path stringByReplacingOccurrencesOfString:@"/rest/" withString:@""];
        return [normalizeRequestPath isEqualToString:kPathConfigsRiderGlobal] && [request.URL.query containsString:@"configAttributes=driverRegistration"] && [request.HTTPMethod isEqualToString:@"GET"];
    } withStubResponse:[OHHTTPStubs handlerResponseWithStatusCode:200 andFileName:@"CONFIG_CITY_DETAIL_AUSTIN"]];
}

- (void)driverTermsStub {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"DriverTerms" ofType:@"txt"];
    NSString *termResponse = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [OHHTTPStubs addStubWithGETRequestPath:@"/download/DriverTermsAustin.txt" statusCode:200 andResponseString:termResponse];
}

- (void)driverAcceptTermsStub {
    [OHHTTPStubs addStubWithPUTRequestPath:@"drivers/terms/1" responseHandler:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        agreedToLegalTerms = YES;
        return [OHHTTPStubs handlerResponseWithStatusCode:200 andResponseString:@""](request);
    }];
}

- (void)driversCarTypesStub {
    [OHHTTPStubs addStubWithGETRequestPath:kPathDriversCarTypes statusCode:200 andResponseFileName:@"DRIVERS_CAR_TYPES_200"];
}

- (void)declineRideStub {
    [OHHTTPStubs addStubWithDELETERequestPath:@"rides/1233369/decline" responseHandler:[OHHTTPStubs handlerWithString:@"" andBlock:^{
        [[EventStubGenerator shared] updateRideStatusWithStatus:RARideStatusUnknown];
    }]];
}

- (void)cancelRideStub {
    [OHHTTPStubs addStubWithDELETERequestPath:@"rides/1233369" responseHandler:[OHHTTPStubs handlerWithString:@"" andBlock:^{
        [[EventStubGenerator shared] updateRideStatusWithStatus:RARideStatusDriverCancelled];
    }]];
}

- (void)receivedRideStub {
    [OHHTTPStubs addStubWithPOSTRequestPath:@"rides/1233369/received" statusCode:200 andResponseString:@""];
}

-(void)acceptRideRequestStub {
    NSString *path = @"rides/1233369/accept";
    [OHHTTPStubs addStubWithPOSTRequestPath:path responseHandler:[OHHTTPStubs handlerWithString:@"" andBlock:^{
        [[EventStubGenerator shared] updateRideStatusWithStatus:RARideStatusDriverAssigned];
    }]];
}

-(void)sendArrivedStub{
    NSString *path = @"rides/1233369/reached";
    [OHHTTPStubs addStubWithPOSTRequestPath:path responseHandler:[OHHTTPStubs handlerWithString:@"" andBlock:^{
        [[EventStubGenerator shared] updateRideStatusWithStatus:RARideStatusDriverReached];
    }]];
}

-(void)sendStartTripStub{
    NSString *path = @"rides/1233369/start";
    [OHHTTPStubs addStubWithPOSTRequestPath:path responseHandler:[OHHTTPStubs handlerWithString:@"" andBlock:^{
        [[EventStubGenerator shared] updateRideStatusWithStatus:RARideStatusActive];
    }]];
}

-(void)getRideByIDStub {
    NSString *path = @"rides/1233369";
    [OHHTTPStubs addStubWithGETRequestPath:path responseHandler:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSDictionary *object = [EventStubGenerator shared].currentRideDictionary;
        if (object) {
            return [OHHTTPStubsResponse responseWithJSONObject:object statusCode:200 headers:nil];
        } else {
            NSError *error = [NSError errorWithDomain:@"com.rideaustin" code:-1 userInfo:@{NSLocalizedDescriptionKey : @"Ride does not exist"}];
            return [OHHTTPStubsResponse responseWithError:error];
        }
    }];
}

-(void)sendEndTripStub{
    NSString *path = @"rides/1233369/end";
    [OHHTTPStubs addStubWithPOSTRequestPath:path responseHandler:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        [[EventStubGenerator shared] updateRideStatusWithStatus:RARideStatusCompleted];
        NSDictionary *object = [EventStubGenerator shared].currentRideDictionary;
        return [OHHTTPStubsResponse responseWithJSONObject:object statusCode:200 headers:nil];
    }];
}

-(void)sendRatingStub{
    NSString *path = @"rides/1233369/rating";
    [OHHTTPStubs addStubWithPUTRequestPath:path responseHandler:[OHHTTPStubs handlerWithString:@"" andBlock:^{
        [[EventStubGenerator shared] updateRideStatusWithStatus:RARideStatusUnknown];
    }]];
}

- (void)earningMapStub {
    NSString *path = [NSString stringWithFormat:kPathRideMap, @1235036];
    [OHHTTPStubs addStubWithGETRequestPath:path responseHandler:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSDictionary *response = @{@"url" : @"https://s3.amazonaws.com/media-stage.rideaustin.com/ride-maps/809c234d-9048-4364-8a3a-13e8b95d35af.png?AWSAccessKeyId=AKIAJRZKPEUYYX2JFKEA&Expires=1511899683&Signature=SzEaxqW6sbJScDSVrgSHVXw3eUg%3D"};
        return [OHHTTPStubsResponse responseWithJSONObject:response statusCode:200 headers:nil];
    }];
}

- (void)disableRequestUpgradeStub {
    [OHHTTPStubs addStubWithGETRequestPath:kPathConfigsDriverGlobal responseHandler:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"CONFIG_GLOBAL_200" ofType:@"json"];
        NSData *jsonData = [NSData dataWithContentsOfFile:path];
        NSMutableDictionary *jsonDict = [[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil] mutableCopy];
        jsonDict[@"rideUpgrade"] = nil;
        return [OHHTTPStubsResponse responseWithJSONObject:jsonDict statusCode:200 headers:nil];
    }];
}

- (void)requestUpgradeStub {
    [OHHTTPStubs addStubWithPOSTRequestPath:kPathRideUpgradeRequest responseHandler:[OHHTTPStubs handlerWithString:@"" andBlock:^{
        [[EventStubGenerator shared] setUpgradeRequestedToCurrentRideWithSource:@"REGULAR" andTarget:@"SUV"];
    }]];
}

- (void)cancelUpgradeStub {
    [OHHTTPStubs addStubWithPOSTRequestPath:kPathRideUpgradeDecline statusCode:200 andResponseString:@""];
}

- (void)currentRideWithUpgradeRequestedStub {
    [OHHTTPStubs addStubWithGETRequestPath:kPathCurrentRide responseHandler:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"RIDE_WITHOUT_COMMENT" ofType:@"json"];
        NSData *jsonData = [NSData dataWithContentsOfFile:path];
        NSMutableDictionary *jsonDict = [[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil] mutableCopy];
        
        RideRequestUpgrade *upgradeRequested = [[RideRequestUpgrade alloc] init];
        upgradeRequested.source = @"REGULAR";
        upgradeRequested.target = @"STANDARD";
        upgradeRequested.status = UpgradeRequested;
        
        jsonDict[@"upgradeRequest"] = [MTLJSONAdapter JSONDictionaryFromModel:upgradeRequested error:nil];
        jsonDict[@"status"] = @"DRIVER_ASSIGNED";
        return [OHHTTPStubsResponse responseWithJSONObject:jsonDict statusCode:200 headers:nil];
    }];
}

- (void)setupDefaultLocationManager {
    CLLocationManagerMock *locationManager = [[CLLocationManagerMock alloc] init];
    locationManager.defaultLocation = [[CLLocation alloc] initWithLatitude:30.4172743 longitude:-97.7501108];
    locationManager.locationStateMapping = @{ @(GoingToPickUpDriverState) : @"DriverOnWayLocations" };
    [[LocationService sharedService] setLocationManager:locationManager];
    [[LocationService sharedService] start];
}

- (void)driverTypesStub {
    [OHHTTPStubs addStubWithGETRequestPath:kPathDriverTypes statusCode:200 andResponseFileName:@"DRIVER_TYPES_200"];
}

@end

#import "NSDate+Utils.h"
@implementation AppDelegate (Earnings)
- (void)presentEarningsStub {
    NSNumber *driverId = @(2187);
    [self stubGetOnlineWithDriverId:driverId];
    [self stubGetRidesWithDriverId:driverId];
}
- (void)stubGetOnlineWithDriverId:(NSNumber *)driverId {
    NSString *path = [NSString stringWithFormat:kPathDriversOnline, driverId];
    NSString *fileName = [NSString stringWithFormat:@"DRIVERS_%@_ONLINE",driverId];
    [OHHTTPStubs addStubWithGETRequestPath:path statusCode:200 andResponseFileName:fileName];
}
- (void)stubGetRidesWithDriverId:(NSNumber *)driverId {

    RideFareDataModel *rideFare = [RideFareDataModel modelFromFileName:@"RIDE_FARE_COMPLETED"];
    rideFare.completedOn = [NSDate trueDate].weekDates.firstObject;
    rideFare.startedOn   = [rideFare.completedOn dateByAddingTimeInterval:-600];
    
    DriverRideEarnings *earnings = [DriverRideEarnings earningsWithRides:@[rideFare]];
    
    NSError *error = nil;
    NSDictionary *json = [MTLJSONAdapter JSONDictionaryFromModel:earnings error:&error];
    NSAssert(error == nil, @"stubGetRidesWithDriverId failed with error:%@", error);
    
    NSString *path = [NSString stringWithFormat:kPathDriversRides, driverId];
    [OHHTTPStubs addStubWithGETRequestPath:path
                           responseHandler:[OHHTTPStubs handlerResponseWithJSONObject:json]];
}
@end

@implementation AppDelegate (SupportTopicsAPIStubs)
- (void)supportTopicsStubs {
    [self supportTopicsListDriverStub];
    [self supportTopicsChildrenStubForTopicId:@(2)];
    [self supportTopicsFormStubForTopicId:@(3)];
    
    //submission
    [self lostAndFoundFoundStub];
}
- (void)supportTopicsListDriverStub {
    [OHHTTPStubs addStubWithGETRequestPath:kPathSupportTopic statusCode:200 andResponseFileName:@"SUPPORTTOPICS_LIST_DRIVER_200"];
}
- (void)supportTopicsFormStubForTopicId:(NSNumber *)supportTopicId {
    NSString *path = [NSString stringWithFormat:kPathSupportTopicForm,supportTopicId];
    NSString *fileName = [NSString stringWithFormat:@"SUPPORTTOPICS_%@_FORM_200",supportTopicId];
    [OHHTTPStubs addStubWithGETRequestPath:path statusCode:200 andResponseFileName:fileName];
}
- (void)supportTopicsChildrenStubForTopicId:(NSNumber *)supportTopicId {
    NSString *path = [NSString stringWithFormat:kPathSupportTopicChildren,supportTopicId];
    NSString *fileName = [NSString stringWithFormat:@"SUPPORTTOPICS_%@_CHILDREN_200",supportTopicId];
    [OHHTTPStubs addStubWithGETRequestPath:path statusCode:200 andResponseFileName:fileName];
}
- (void)lostAndFoundFoundStub {
    //NOT YET TESTED
    NSString *path = kPathLostAndFoundFound;
    NSArray *requiredParameters
    = @[
        ];
    /*
     image : NSData
     item : 
     
    {
        details = ok;
        foundOn = "2017-06-08T06:30:24Z";
        rideDescription = maybe;
        rideId = 1234881;
        sharingContactsAllowed = 0;
    }
    */
    [OHHTTPStubs addStubWithRequestPath:path
                                 method:@"POST"
                             statusCode:200
                            andFileName:@"LOSTANDFOUND_FOUND_200"
                    requiringParameters:requiredParameters];
}
@end
@implementation AppDelegate (EventStubGenerator)
- (void)createEventStubsFromArguments:(NSArray<NSString *>*)arguments {
    EventStubGenerator *generator = [EventStubGenerator shared];
    [generator loadArguments:arguments];
    [self createEventStubsFromScenario];
    [self createCurrentRideStub];
}
- (void)createEventStubsFromScenario {
    int code = 200;
    
    [OHHTTPStubs addStubWithGETRequestPath:kPathEvents responseHandler:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        
        for (EventStubModel *event in [EventStubGenerator shared].eventModels) {
            if (event.model.modelID.integerValue == NSNotFound) {
                return OHHTTPStubsResponse.emptyJSONArray;
            } else {
                if (event.isInPresentOrPast) {
                    if ([event isNotYetReceivedByRequest:request]) {
                        id jsonArray = event.jsonArray.copy;
                        [[EventStubGenerator shared] willDispatchEvent:event];
                        return [OHHTTPStubsResponse responseWithJSONObject:jsonArray statusCode:code headers:nil];
                    } else {
                        //check next event
                    }
                } else {
                    return OHHTTPStubsResponse.emptyJSONArray;
                }
            }
        }
        return OHHTTPStubsResponse.emptyJSONArray;
    }];
}
-(void)createCurrentRideStub {
    [OHHTTPStubs addStubWithGETRequestPath:kPathCurrentRide responseHandler:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSDictionary *object = [EventStubGenerator shared].currentRideDictionary;
        return [OHHTTPStubsResponse responseWithJSONObject:object statusCode:200 headers:nil];
    }];
}
@end
