//
//  GoogleMapsManager+Facade.m
//  RideDriver
//
//  Created by Robert on 15/3/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "GoogleMapsManager+Facade.h"

#import <objc/runtime.h>

#import "RideDriver-Swift.h"
#import "UIColor+HexUtils.h"
#import "RAAlertManager.h"

#import <GoogleMaps/GoogleMaps.h>

//zIndex Markers
#define routeZIndex 1
#define carZIndex 2
#define nextTripZIndex 3
#define pinZIndex 4
#define pinBlueUserZIndex 5

//Marker Identifieres
#define kRiderLocationMarker @"riderLocationMarker"
#define kPickupMarker @"startLocationMarker"
#define kDestinationMarker @"endLocationMarker"
#define kDriverCarMarker @"driverCar"
#define kNearbyCar  @"nearbyCar"
#define kNextTripMarker @"nextTripMarker"

@implementation GoogleMapsManager (Facade)

#pragma mark - Default MapView Configuration

- (void)defaultMapConfigurationWithDelegate:(id<GMSMapViewDelegate>)delegate andLocation:(CLLocation*)location {
    
    [self configureMapViewWithBlock:^(GMSMapView * _Nonnull mapView) {
        const CGFloat kLocationViewControllerMapDefaultZoomAdjustment = 4.0;
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithTarget:location.coordinate
                                                                   zoom:kGMSMaxZoomLevel - kLocationViewControllerMapDefaultZoomAdjustment];
        
        [mapView setCamera:camera];
        mapView.indoorEnabled = NO;
        mapView.settings.allowScrollGesturesDuringRotateOrZoom = NO;
        mapView.settings.scrollGestures = YES;
        mapView.delegate = delegate;
        mapView.mapType = kGMSTypeNormal;
        mapView.settings.rotateGestures = NO;
        mapView.myLocationEnabled = NO;
        
        //Configure Maps Padding (Top, Left, Bottom, Right) ~ Default
        mapView.padding = UIEdgeInsetsMake(0.0, 0.0, 12.0, 12.0);
    }];
    
}

#pragma mark - Create or Update Markers

- (void)createOrUpdatePickupMarkerWithCoordinate:(CLLocationCoordinate2D)coordinate {
    GMSMarker *marker = [self markerWithIdentifier:kPickupMarker];
    if (marker) {
        marker.position = coordinate;
    } else {
        [self addMarkerToCoordinates:coordinate withIdentifier:kPickupMarker icon:[UIImage imageNamed:@"green-pin"] zIndex:pinZIndex];
    }
}

- (void)createOrUpdateDestinationMarkerWithCoordinate:(CLLocationCoordinate2D)coordinate {
    GMSMarker *marker = [self markerWithIdentifier:kDestinationMarker];
    if (marker) {
        marker.position = coordinate;
    } else {
        [self addMarkerToCoordinates:coordinate withIdentifier:kDestinationMarker icon:[UIImage imageNamed:@"red-pin"] zIndex:pinZIndex];
    }
}

- (void)createOrUpdateRiderMarkerWithCoordinate:(CLLocationCoordinate2D)coordinate {
    GMSMarker *marker = [self markerWithIdentifier:kRiderLocationMarker];
    marker.accessibilityValue = [NSString stringWithFormat:@"{\"lat\":%f,\"lon\":%f}",coordinate.latitude,coordinate.longitude];
    if (marker) {
        marker.position = coordinate;
    } else {
        [self addMarkerToCoordinates:coordinate withIdentifier:kRiderLocationMarker icon:[UIImage imageNamed:@"user-red-location-icon"] zIndex:pinBlueUserZIndex];
    }
}

- (void)createOrUpdateNextTripMarkerWithCoordinate:(CLLocationCoordinate2D)coordinate {
    GMSMarker *marker = [self markerWithIdentifier:kNextTripMarker];
    if (marker) {
        marker.position = coordinate;
    } else {
        [self addMarkerToCoordinates:coordinate withIdentifier:kNextTripMarker icon:[UIImage imageNamed:@"next-trip-marker-icon"] zIndex:nextTripZIndex];
    }
}

#pragma mark - Create or Update Route Marker

- (void)setFirstDrawRoute:(BOOL)firstDrawRoute {
    objc_setAssociatedObject(self, @selector(firstDrawRoute), @(firstDrawRoute), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)firstDrawRoute {
    NSNumber *boolNumber = objc_getAssociatedObject(self, @selector(firstDrawRoute));
    return [boolNumber boolValue];
}

- (void)setLastTimeDrawRoute:(NSDate *)lastTimeDrawRoute {
    objc_setAssociatedObject(self, @selector(lastTimeDrawRoute), lastTimeDrawRoute, OBJC_ASSOCIATION_RETAIN);
}

- (NSDate *)lastTimeDrawRoute {
    return objc_getAssociatedObject(self, @selector(lastTimeDrawRoute));
}

- (GMSPolyline*)currentRideRoute {
    return [self routeWithIdentifier:kRideRoutePath];
}

- (void)attempToDrawRouteFrom:(CLLocationCoordinate2D)fromCoordinate to:(CLLocationCoordinate2D)toCoordinate {
    [self attempToDrawRouteFrom:fromCoordinate to:toCoordinate completion:nil];
}

- (void)attempToDrawRouteFrom:(CLLocationCoordinate2D)fromCoordinate to:(CLLocationCoordinate2D)toCoordinate completion:(void(^)(void))completion {
    if (![self currentRideRoute]) {
        [self createRouteFrom:fromCoordinate to:toCoordinate completion:completion];
        self.firstDrawRoute = YES;
        return;
    }
    
    if ([self shouldRedrawRideRouteWithPolyline:[self currentRideRoute] andCoordinate:fromCoordinate]) {
        if (self.firstDrawRoute && ![self shouldRedrawBasedOnTimeOut]) {
            return;
        }
        
        self.lastTimeDrawRoute = [NSDate date];
        [self createRouteFrom:fromCoordinate to:toCoordinate completion:completion];
    } else {
        self.firstDrawRoute = NO;
    }
}

- (BOOL)shouldRedrawRideRouteWithPolyline:(GMSPolyline*)polyline andCoordinate:(CLLocationCoordinate2D)coordinate {
    const CGFloat tolerance = 5;
    return !GMSGeometryIsLocationOnPathTolerance(coordinate, polyline.path, YES, tolerance);
}

- (BOOL)shouldRedrawBasedOnTimeOut {
    NSTimeInterval timeOutInterval = 10.0;
    return ![self lastTimeDrawRoute] || (ABS([[self lastTimeDrawRoute] timeIntervalSinceNow]) > timeOutInterval);
}

- (void)createRouteFrom:(CLLocationCoordinate2D)fromCoordinate to:(CLLocationCoordinate2D)toCoordinate completion:(void(^)(void))completion {
    [self getRouteFrom:fromCoordinate to:toCoordinate completion:^(GMSPolyline * _Nullable polyline, GMSCoordinateBounds * _Nullable bounds, NSError * _Nullable error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (error) {
                [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive]];
            } else {
                
                if ([self currentRideRoute]) {
                    [self updateRoutePathWithIdentifier:kRideRoutePath andPath:polyline.path];
                } else {
                    polyline.strokeWidth = 8;
                    polyline.strokeColor = [UIColor colorWithHex:@"#00AEEF" alpha:0.6];
                    polyline.zIndex = routeZIndex;
                    [self drawRoute:polyline withIdentifier:kRideRoutePath];
                }
                
                if (completion) {
                    completion();
                }
            }
        }];
    }];
}

#pragma mark - Car Marker

- (void)createCarMarkerWithCoordinate:(CLLocationCoordinate2D)coordinate {
    [self addMarkerToCoordinates:coordinate withIdentifier:kDriverCarMarker icon:[UIImage imageNamed:@"car"] zIndex:carZIndex];
    GMSMarker *carMarker = [self carMarker];
    carMarker.groundAnchor = CGPointMake(.5, .5);
    carMarker.accessibilityLabel = @"carMarker";
    carMarker.accessibilityValue = [NSString stringWithFormat: @"{\"lat\":%f,\"lon\":%f}",coordinate.latitude,coordinate.longitude];
}

- (void)updateCarWithHeading:(CLLocationDirection)heading {
    [self carMarker].rotation = heading;
}

- (void)updateCarWithCoordinate:(CLLocationCoordinate2D)coordinate {
    GMSMarker *carMarker = [self carMarker];
    carMarker.position = coordinate;
    carMarker.accessibilityValue = [NSString stringWithFormat: @"{\"lat\":%f,\"lon\":%f}",coordinate.latitude,coordinate.longitude];
}

- (GMSMarker *)carMarker {
    return [self markerWithIdentifier:kDriverCarMarker];
}

#pragma mark - Nearby Cars

- (void)setCurrentNearbyCarsIdentifier:(NSMutableArray<NSString *> *)currentNearbyCarsIdentifier {
    objc_setAssociatedObject(self, @selector(currentNearbyCarsIdentifier), currentNearbyCarsIdentifier, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray<NSString *> *)currentNearbyCarsIdentifier {
    return objc_getAssociatedObject(self, @selector(currentNearbyCarsIdentifier));
}

- (void)showNearbyDriversWithList:(NSArray<RAActiveDriversCar *> *)drivers excludingCurrentUser:(NSInteger)currentUserId {
    
    if (!self.currentNearbyCarsIdentifier) {
        self.currentNearbyCarsIdentifier = [[NSMutableArray alloc] init];
    }
    
    NSMutableArray<NSString*> *tmpCurrentNearbyCarsIdentifiers = [[NSMutableArray alloc] init];
    for (RAActiveDriversCar *car in drivers) {
        NSNumber *userId = car.driver.user.modelID;
        
        if (!userId || currentUserId == userId.integerValue) {
            continue;
        }
        
        NSString *nearbyCarIdentifier = [NSString stringWithFormat:@"%@-%@", kNearbyCar, userId.stringValue];
        GMSMarker *nearbyCar = [self markerWithIdentifier:nearbyCarIdentifier];
        if (nearbyCar) {
            nearbyCar.position = car.coordinate;
            nearbyCar.rotation = car.course.doubleValue ;
        } else {
            [self addMarkerToCoordinates:car.coordinate
                          withIdentifier:nearbyCarIdentifier
                                    icon:[UIImage imageNamed:@"car"]
                                  zIndex:0
                             andRotation:car.course.doubleValue];
            
            //Extra customization
            nearbyCar = [self markerWithIdentifier:nearbyCarIdentifier];
            nearbyCar.opacity = 0.6;
            nearbyCar.groundAnchor = CGPointMake(.5, .5);
            
            #ifdef AUTOMATION
            nearbyCar.accessibilityElementsHidden = NO;
            nearbyCar.accessibilityLabel = [NSString stringWithFormat:@"DRIVER:%@",userId];
            #endif
        }
        
        [tmpCurrentNearbyCarsIdentifiers addObject:nearbyCarIdentifier];
    }
    
    //Clear cars drivers not in list
    [self.currentNearbyCarsIdentifier removeObjectsInArray:tmpCurrentNearbyCarsIdentifiers];
    for (NSString *nearbyCarIdentifier in self.currentNearbyCarsIdentifier) {
        [self removeMarkerWithIdentifier:nearbyCarIdentifier];
    }
    
    self.currentNearbyCarsIdentifier = tmpCurrentNearbyCarsIdentifiers;
}

#pragma mark - Remove Markers

- (void)removePickupMarker {
    [self removeMarkerWithIdentifier:kPickupMarker];
}

- (void)removeDestinationMarker {
    [self removeMarkerWithIdentifier:kDestinationMarker];
}

- (void)removeRiderMarker {
    [self removeMarkerWithIdentifier:kRiderLocationMarker];
}

- (void)removeRideRoute {
    [self eraseRouteWithIdentifier:kRideRoutePath];
}

- (void)removeAllNearbyDrivers {
    for (NSString *nearbyCarIdentifier in self.currentNearbyCarsIdentifier) {
        [self removeMarkerWithIdentifier:nearbyCarIdentifier];
    }
    [self.currentNearbyCarsIdentifier removeAllObjects];
}

- (void)removeNextTripMarker {
    [self removeMarkerWithIdentifier:kNextTripMarker];
}

- (void)clearRideMarkers {
    [self removePickupMarker];
    [self removeDestinationMarker];
    [self removeRiderMarker];
    [self removeRideRoute];
}

@end
