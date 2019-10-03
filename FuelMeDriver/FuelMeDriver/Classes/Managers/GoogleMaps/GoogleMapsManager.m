//
//  GoogleMapsManager.m
//  Ride
//
//  Created by Kitos on 9/8/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "GoogleMapsManager.h"
#import "ErrorReporter.h"
#define kGoogleAPIDirectionsUrl @"http://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&sensor=false&mode=driving"

@interface GoogleMapsManager ()

@property (nonatomic, strong) GMSMapView *mapView;

@property (nonatomic, strong) NSMutableDictionary <NSString *, GMSMarker*> *markers;
@property (nonatomic, strong) NSMutableDictionary <NSString *, GMSPolyline*> *routes;

@end

@interface GMSPath (Span)

-(GMSCoordinateBounds*)bounds;

@end

@implementation GoogleMapsManager

-(instancetype)initWithMap:(GMSMapView *)mapView {
    self = [super init];
    
    if (self) {
        self.mapView = mapView;
    }
    
    return self;
}

@end

#pragma mark - Map

@implementation GoogleMapsManager (Map)

-(void)setPadding:(UIEdgeInsets)padding{
    self.mapView.padding = padding;
}

-(UIEdgeInsets)getPadding{
    return self.mapView.padding;
}

-(CLLocation*)getMyCurrentLocation {
    return self.mapView.myLocation;
}

@end

#pragma mark - Markers

@implementation GoogleMapsManager (Markers)

-(void)addMarkerToCoordinates:(CLLocationCoordinate2D)coords withIdentifier:(NSString *)identifier icon:(UIImage *)icon{
    
    GMSMarker *marker = [GMSMarker markerWithPosition:coords];
    marker.icon = icon;
    marker.map = self.mapView;
    marker.appearAnimation = kGMSMarkerAnimationPop;
    
    [self addMarker:marker withIdentifier:identifier toCoordinates:coords];
    
}

-(void)addMarker:(GMSMarker *)marker withIdentifier:(NSString *)identifier toCoordinates:(CLLocationCoordinate2D)coords{

    [self removeMarkerWithIdentifier:identifier];
    
    if (self.markers) {
        self.markers[identifier] = marker;
    }
    else {
        self.markers = [NSMutableDictionary dictionaryWithObject:marker forKey:identifier];
    }
    
}

-(void)removeMarkerWithIdentifier:(NSString *)identifier{
    GMSMarker *marker = self.markers[identifier];
    marker.map = nil;
    [self.markers removeObjectForKey:identifier];
}

@end

#pragma mark - Camera

@implementation GoogleMapsManager (Camera)


-(void)animateToLocation:(CLLocationCoordinate2D)coordinate{
    [self.mapView animateToLocation:coordinate];
}

-(void)animateToZoom:(float)zoom{
    [self.mapView animateToZoom:zoom];
}

-(void)animateCameraToCoordinate:(CLLocationCoordinate2D)coordinate{
    [self animateCameraToCoordinate:coordinate zoom:self.mapView.camera.zoom];
}

-(void)animateCameraToCoordinate:(CLLocationCoordinate2D)coordinate zoom:(float)zoomLevel{
    GMSCameraPosition *camPos = [GMSCameraPosition cameraWithTarget:coordinate zoom:zoomLevel];
    [self.mapView animateToCameraPosition:camPos];
}

-(void)animateCameraToFitStartCoordinate:(CLLocationCoordinate2D)start endCoordinate:(CLLocationCoordinate2D)end withEdgeInsets:(UIEdgeInsets)insets{
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:start coordinate:end];
    [self animateCameraToFitBounds:bounds withEdgeInsets:insets];
}

-(void)animateCameraToFitBounds:(GMSCoordinateBounds *)bounds withEdgeInsets:(UIEdgeInsets)insets{
    [self.mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withEdgeInsets:insets]];
}

@end

#pragma mark - Route

@implementation GoogleMapsManager (Route)

-(void)getRouteFrom:(CLLocationCoordinate2D)from to:(CLLocationCoordinate2D)to completion:(void (^)(GMSPolyline * _Nullable, GMSCoordinateBounds * _Nullable, NSError * _Nullable))handler{
    CLLocation *fromLocation = [[CLLocation alloc] initWithLatitude:from.latitude longitude:from.longitude];
    CLLocation *toLocation = [[CLLocation alloc] initWithLatitude:to.latitude longitude:to.longitude];
    
    if ([fromLocation isValid] && [toLocation isValid]) {
        
        NSString *path = [NSString stringWithFormat:kGoogleAPIDirectionsUrl, from.latitude, from.longitude, to.latitude, to.longitude];
        NSURL *url = [[NSURL alloc] initWithString:path];
        
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url]
                                           queue:queue
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   if (error) {
                                       [ErrorReporter recordError:error withDomainName:GOOGLEGetRoute];
                                       handler(nil, nil, error);
                                   } else {
                                       NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                                            options:NSJSONReadingMutableContainers
                                                                                              error:nil];
                                       NSArray *routes = [json objectForKey:@"routes"];
                                       NSDictionary *routeJson = [routes firstObject];
                                       NSDictionary *routeOverviewPolyline = [routeJson objectForKey:@"overview_polyline"];
                                       NSString *points = [routeOverviewPolyline objectForKey:@"points"];
                                       
                                       GMSPath *path = [GMSPath pathFromEncodedPath:points];
                                       GMSCoordinateBounds *bounds = [path bounds];
                                       //fixed crash on create polyline in background
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
                                           handler(polyline, bounds,nil);
                                       });
                                   }
                               }
         ];

    }
    else{
        NSError *error = [NSError errorWithDomain:@"com.rideaustin.route.error" code:-1 userInfo:@{NSLocalizedRecoverySuggestionErrorKey: [NSString stringWithFormat: @"Invalid coordinates[from:(%f,%f) - to:(%f,%f)]",from.latitude,from.longitude,to.latitude,to.longitude]}];
        [ErrorReporter recordErrorDomainName:GOOGLEGetRoute withUserInfo:@{@"logs":[NSString stringWithFormat: @"Invalid coordinates[from:(%f,%f) - to:(%f,%f)]",from.latitude,from.longitude,to.latitude,to.longitude]}];
        handler(nil, nil, error);
    }
}

-(void)drawRoute:(GMSPolyline *)route withIdentifier:(NSString *)identifier{
    
    [self eraseRoutWithIdentifier:identifier];

    route.map = self.mapView;
    
    if (self.routes) {
        self.routes[identifier] = route;
    }
    else {
        self.routes = [NSMutableDictionary dictionaryWithObject:route forKey:identifier];
    }

}

-(void)eraseRoutWithIdentifier:(NSString *)identifier{
    GMSPolyline *route = self.routes[identifier];
    route.map = nil;
    
    [self.routes removeObjectForKey:identifier];
}

-(GMSCoordinateBounds *)boundsForRouteWithIdentifier:(NSString *)identifier{
    
    GMSPolyline *route = self.routes[identifier];
    
    if (route) {
        return [route bounds];
    }
    else{
        return nil;
    }
    
}

@end

#pragma mark - GMSPolyline
#pragma mark - Sapn

@implementation GMSPolyline (Span)

-(GMSCoordinateBounds *)bounds{
    return [self.path bounds];
}

@end

#pragma mark - GMSPath

#pragma mark - Utils

@implementation GMSPath (Utils)

+(GMSPath *)pathWithLocations:(NSArray<CLLocation *> *)locations{
    GMSMutablePath *mPath = [[GMSMutablePath alloc] init];
    for (CLLocation *location in locations) {
        [mPath addCoordinate:location.coordinate];
    }
    
    return [[GMSPath alloc] initWithPath:mPath];
}

+(BOOL)location:(CLLocation *)location isInsidePath:(GMSPath *)path{
    return GMSGeometryContainsLocation(location.coordinate, path, YES);
}

+(BOOL)location:(CLLocation *)location isInsidePathFromLocations:(NSArray<CLLocation *> *)locations{
    GMSPath *path = [GMSPath pathWithLocations:locations];
    return [GMSPath location:location isInsidePath:path];
}

@end

#pragma mark Span

@implementation GMSPath (Span)

-(GMSCoordinateBounds *)bounds{
    
    if (self.count > 0) {
        
        CLLocationDegrees minLat;
        CLLocationDegrees minLon;
        CLLocationDegrees maxLat;
        CLLocationDegrees maxLon;
        
        CLLocationCoordinate2D coord = [self coordinateAtIndex:0];
        
        minLat = coord.latitude;
        minLon = coord.longitude;
        maxLat = coord.latitude;
        maxLon = coord.longitude;
        
        for (NSInteger i = 1; i<self.count; i++) {
            coord = [self coordinateAtIndex:i];
            
            if (coord.latitude < minLat) {
                minLat = coord.latitude;
            }
            if (coord.longitude < minLon) {
                minLon = coord.longitude;
            }
            if (coord.latitude > maxLat) {
                maxLat = coord.latitude;
            }
            if (coord.longitude > maxLon) {
                maxLon = coord.longitude;
            }
        }
        
        CLLocationCoordinate2D minCoord = CLLocationCoordinate2DMake(minLat, minLon);
        CLLocationCoordinate2D maxCoord = CLLocationCoordinate2DMake(maxLat, maxLon);
        
        return [[GMSCoordinateBounds alloc] initWithCoordinate:minCoord coordinate:maxCoord];
        
    }
    else {
        return nil;
    }
    
}

@end

#pragma mark - CLLocation
#pragma mark - Validation

@implementation CLLocation (Validation)

-(BOOL)isValid{
    CLLocationCoordinate2D coord = self.coordinate;
    return CLLocationCoordinate2DIsValid(coord) && ((coord.latitude != 0) || (coord.longitude != 0));
}

@end

#pragma mark Equality

@implementation CLLocation (Equality)

-(BOOL)isEqualToOtherLocation:(CLLocation *)otherLocation{
    NSString *lat1 = [NSString stringWithFormat:@"%f",self.coordinate.latitude];
    NSString *lat2 = [NSString stringWithFormat:@"%f",otherLocation.coordinate.latitude];
    NSString *lon1 = [NSString stringWithFormat:@"%f",self.coordinate.longitude];
    NSString *lon2 = [NSString stringWithFormat:@"%f",otherLocation.coordinate.longitude];
    return [lat1 isEqualToString:lat2] && [lon1 isEqualToString:lon2];
}

@end

#pragma mark Utils

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiansToDegrees(x) (x * 180.0 / M_PI)

@implementation CLLocation (Utils)

-(CLLocationDegrees)getHeadingToOtherCoordinate:(CLLocationCoordinate2D)otherCoord{
    CLLocationDegrees fLat = degreesToRadians(self.coordinate.latitude);
    CLLocationDegrees fLng = degreesToRadians(self.coordinate.longitude);
    CLLocationDegrees tLat = degreesToRadians(otherCoord.latitude);
    CLLocationDegrees tLng = degreesToRadians(otherCoord.longitude);
    
    CLLocationDegrees degree = radiansToDegrees(atan2(sin(tLng-fLng)*cos(tLat), cos(fLat)*sin(tLat)-sin(fLat)*cos(tLat)*cos(tLng-fLng)));
    
    if (degree >= 0) {
        return degree;
    } else {
        return 360+degree;
    }
}

-(CLLocationCoordinate2D)coordinateWithBearing:(CLLocationDegrees)bearing andDistance:(CLLocationDistance)meters{
    CLLocationDegrees distRadians = meters / (6372797.6); // earth radius in meters
    CLLocationDegrees bearingRadians = degreesToRadians(bearing);
    
    CLLocationDegrees lat1 = degreesToRadians(self.coordinate.latitude);
    CLLocationDegrees lon1 = degreesToRadians(self.coordinate.longitude);
    
    CLLocationDegrees lat2 = asin( sin(lat1) * cos(distRadians) + cos(lat1) * sin(distRadians) * cos(bearingRadians));
    CLLocationDegrees lon2 = lon1 + atan2( sin(bearingRadians) * sin(distRadians) * cos(lat1),
                              cos(distRadians) - sin(lat1) * sin(lat2) );
    lon2 = fmod((lon2 + 3*M_PI), (2*M_PI)) - M_PI; // adjust toLonRadians to be in the range -180 to +180...
    
    CLLocationCoordinate2D target;
    target.latitude = radiansToDegrees(lat2);
    target.longitude = radiansToDegrees(lon2);
    
    return target;
}

-(CLLocationCoordinate2D)coordinateOppositeToOtherCoordinate:(CLLocationCoordinate2D)otherCoordinate{
    CLLocation *otherLocation = [[CLLocation alloc] initWithLatitude:otherCoordinate.latitude longitude:otherCoordinate.longitude];
    CLLocationDistance distance = [self distanceFromLocation:otherLocation];
    CLLocationDegrees bearing = [otherLocation getHeadingToOtherCoordinate:self.coordinate];

    return [self coordinateWithBearing:bearing andDistance:distance];
}

-(CLLocationCoordinate2D)middleCoordinateToOtherCoordinate:(CLLocationCoordinate2D)otherCoordinate{
    CLLocationDegrees lat = (self.coordinate.latitude +otherCoordinate.latitude)/2.0;
    CLLocationDegrees lon = (self.coordinate.longitude +otherCoordinate.longitude)/2.0;
    
    return CLLocationCoordinate2DMake(lat, lon);
}

@end

