//
//  RAActiveDriverPolling.m
//  RideDriver
//
//  Created by Roberto Abreu on 7/21/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RAActiveDriverPolling.h"

#import "ConfigurationManager.h"
#import "DriverManager.h"
#import "LocationService.h"
#import "NetworkManager.h"
#import "RASessionManager.h"
#import "RideDriver-Swift.h"

#define kIntervalGetDrivers 60

@interface RAActiveDriverPolling ()

@property (strong, nonatomic) NSTimer *activeDriversTimer;

@end

@implementation RAActiveDriverPolling

- (instancetype)initWithDelegate:(id<RAActiveDriverPollingDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)start {
    [self stop];
    if (!self.activeDriversTimer) {
        self.activeDriversTimer = [NSTimer timerWithTimeInterval:kIntervalGetDrivers target:self selector:@selector(getActiveDrivers:) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.activeDriversTimer forMode:NSRunLoopCommonModes];
        [self.activeDriversTimer fire];
    }
}

- (void)getActiveDrivers:(NSTimer*)timer {
    if ([RASessionManager shared].isSignedIn && [DriverManager shared].isDriverOnActiveRide == NO) { //RA-7629. Ensure that active drivers are not drawn while in a ride.
        CLLocationCoordinate2D coordinate = [LocationService sharedService].myLocation.coordinate;
        NSInteger cityId = [ConfigurationManager shared].global.currentCity.cityID.integerValue;
        [RAActiveDriversAPI getActiveDriversFromLocation:coordinate cityId:cityId completion:^(NSArray<RAActiveDriversCar *> *activeDriversCars, NSError *error) {
            if (!error) {
                [self.delegate showActiveDrivers:activeDriversCars];
            }
        }];
    } else {
        [self stop];
        [self.delegate clearActiveDrivers];
    }
}

- (void)stop {
    if (self.activeDriversTimer) {
        [self.activeDriversTimer invalidate];
        self.activeDriversTimer = nil;
    }
}

@end
