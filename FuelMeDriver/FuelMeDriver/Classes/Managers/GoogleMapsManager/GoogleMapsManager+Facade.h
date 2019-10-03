//
//  GoogleMapsManager+Facade.h
//  RideDriver
//
//  Created by Robert on 15/3/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "GoogleMapsManager.h"

#define kRideRoutePath @"routePath"

@interface GoogleMapsManager (Facade)

@property (nonatomic, strong) NSMutableArray<NSString*> *currentNearbyCarsIdentifier;
@property (nonatomic, assign) BOOL firstDrawRoute;
@property (nonatomic, strong) NSDate *lastTimeDrawRoute;

#pragma mark - Default MapView Configuration
- (void)defaultMapConfigurationWithDelegate:(id<GMSMapViewDelegate>)delegate andLocation:(CLLocation*)location;

#pragma mark - Create or Update Pin Markers
- (void)createOrUpdatePickupMarkerWithCoordinate:(CLLocationCoordinate2D)coordinate;
- (void)createOrUpdateDestinationMarkerWithCoordinate:(CLLocationCoordinate2D)coordinate;
- (void)createOrUpdateRiderMarkerWithCoordinate:(CLLocationCoordinate2D)coordinate;
- (void)createOrUpdateNextTripMarkerWithCoordinate:(CLLocationCoordinate2D)coordinate;

#pragma mark - Create or Update Route Marker
- (void)attempToDrawRouteFrom:(CLLocationCoordinate2D)fromCoordinate
                           to:(CLLocationCoordinate2D)toCoordinate;
- (void)attempToDrawRouteFrom:(CLLocationCoordinate2D)fromCoordinate
                           to:(CLLocationCoordinate2D)toCoordinate
                   completion:(void(^)(void))completion;
- (void)createRouteFrom:(CLLocationCoordinate2D)fromCoordinate
                     to:(CLLocationCoordinate2D)toCoordinate
             completion:(void(^)(void))completion;

#pragma mark - Car Marker
- (void)createCarMarkerWithCoordinate:(CLLocationCoordinate2D)coordinate;
- (void)updateCarWithHeading:(CLLocationDirection)heading;
- (void)updateCarWithCoordinate:(CLLocationCoordinate2D)coordinate;
- (GMSMarker*)carMarker;

#pragma mark - Nearby Cars
- (void)showNearbyDriversWithList:(NSArray<NSDictionary*>*)drivers excludingCurrentUser:(NSInteger)currentUserId;

#pragma mark - Remove Markers
- (void)removePickupMarker;
- (void)removeDestinationMarker;
- (void)removeRiderMarker;
- (void)removeRideRoute;
- (void)removeAllNearbyDrivers;
- (void)removeNextTripMarker;
- (void)clearRideMarkers;

@end
