//
//  GoogleMapsManager.m
//  RideAustin
//
//  Created by Kitos on 9/8/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "AppConfig.h"
#import "GoogleMapsManager.h"
#import "ErrorReporter.h"

#define kGoogleAPIDirectionsBaseUrl @"https://maps.googleapis.com/maps/api/directions/json"

@interface GoogleMapsManager ()

@property (nonatomic, strong) GMSMapView *mapView;

@property (nonatomic, strong) NSMutableDictionary <NSString *, GMSMarker*> *markers;
@property (nonatomic, strong) NSMutableDictionary <NSString *, GMSPolyline*> *routes;

@end

@interface GMSPath (Span)

-(GMSCoordinateBounds*)spanBounds;

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

- (void)configureMapViewWithBlock:(void (^)(GMSMapView * _Nonnull))configurationBlock {
    configurationBlock(self.mapView);
}

-(void)setPadding:(UIEdgeInsets)padding{
    self.mapView.padding = padding;
}

-(UIEdgeInsets)getPadding{
    return self.mapView.padding;
}

@end

#pragma mark - Markers

@implementation GoogleMapsManager (Markers)

-(void)addMarkerToCoordinates:(CLLocationCoordinate2D)coords withIdentifier:(NSString* _Nonnull)identifier icon:(UIImage* _Nullable)icon zIndex:(int)zIndex andRotation:(CLLocationDegrees)rotation {
    GMSMarker *marker = [GMSMarker markerWithPosition:coords];
    marker.icon = icon;
    marker.map = self.mapView;
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.zIndex = zIndex;
    marker.rotation = rotation;
    [self addMarker:marker withIdentifier:identifier toCoordinates:coords];
    
#ifdef AUTOMATION
    marker.accessibilityElementsHidden = NO;
    marker.accessibilityLabel = identifier;
#endif
}

-(void)addMarkerToCoordinates:(CLLocationCoordinate2D)coords withIdentifier:(NSString* _Nonnull)identifier icon:(UIImage* _Nullable)icon zIndex:(int)zIndex {
    [self addMarkerToCoordinates:coords withIdentifier:identifier icon:icon zIndex:zIndex andRotation:0];
}

-(void)addMarkerToCoordinates:(CLLocationCoordinate2D)coords withIdentifier:(NSString *)identifier icon:(UIImage *)icon{
    [self addMarkerToCoordinates:coords withIdentifier:identifier icon:icon zIndex:0];
}

-(void)addMarker:(GMSMarker *)marker withIdentifier:(NSString *)identifier toCoordinates:(CLLocationCoordinate2D)coords{
    [self removeMarkerWithIdentifier:identifier];
    if (self.markers) {
        self.markers[identifier] = marker;
    } else {
        self.markers = [NSMutableDictionary dictionaryWithObject:marker forKey:identifier];
    }
}

-(void)updateMarkerWithIdentifier:(NSString * _Nonnull)identifier toPosition:(CLLocationCoordinate2D)coords {
    GMSMarker *marker = [self.markers objectForKey:identifier];
    if (marker) {
        marker.position = coords;
    }
}

-(void)removeMarkerWithIdentifier:(NSString *)identifier{
    GMSMarker *marker = self.markers[identifier];
    marker.map = nil;
    [self.markers removeObjectForKey:identifier];
}

-(GMSMarker*)markerWithIdentifier:(NSString*)identifier {
    return self.markers[identifier];
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
        NSString *origin = [NSString stringWithFormat:@"origin=%f,%f", from.latitude, from.longitude];
        NSString *destin = [NSString stringWithFormat:@"destination=%f,%f", to.latitude, to.longitude];
        NSString *sensor = @"sensor=false";
        NSString *mode   = @"mode=driving";
        NSString *key  = [NSString stringWithFormat:@"key=%@", [AppConfig googleDirectionsKey]];
        NSString *path = [NSString stringWithFormat:@"%@?%@&%@&%@&%@&%@", kGoogleAPIDirectionsBaseUrl, origin, destin, sensor, mode, key];
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
                                       GMSCoordinateBounds *bounds = [path spanBounds];
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

- (GMSPolyline *)routeWithIdentifier:(NSString *)identifier {
    return self.routes[identifier];
}

-(void)drawRoute:(GMSPolyline *)route withIdentifier:(NSString *)identifier{
    [self eraseRouteWithIdentifier:identifier];
    route.map = self.mapView;
    
    if (self.routes) {
        self.routes[identifier] = route;
    } else {
        self.routes = [NSMutableDictionary dictionaryWithObject:route forKey:identifier];
    }
    
#ifdef AUTOMATION
    route.accessibilityElementsHidden = NO;
    route.accessibilityLabel = identifier;
    CLLocationCoordinate2D startCoord = kCLLocationCoordinate2DInvalid;
    CLLocationCoordinate2D endCoord = kCLLocationCoordinate2DInvalid;
    GMSPath *path = route.path;
    if (path.count > 0) {
        startCoord = [path coordinateAtIndex:0];
        endCoord = [path coordinateAtIndex:path.count-1];
    }
    route.accessibilityValue = [NSString stringWithFormat: @"{\"start\":{\"lat\":%f,\"lon\":%f},\"end\":{\"lat\":%f,\"lon\":%f}}",startCoord.latitude,startCoord.longitude,endCoord.latitude,endCoord.longitude];
#endif
    
}

- (void)updateRoutePathWithIdentifier:(NSString*)identifier andPath:(GMSPath*)path {
    GMSPolyline *polyline = self.routes[identifier];
    if (polyline) {
        polyline.path = path;
        
#ifdef AUTOMATION
        CLLocationCoordinate2D startCoord = kCLLocationCoordinate2DInvalid;
        CLLocationCoordinate2D endCoord = kCLLocationCoordinate2DInvalid;
        
        if (path.count > 0) {
            startCoord = [path coordinateAtIndex:0];
            endCoord = [path coordinateAtIndex:path.count-1];
        }
        polyline.accessibilityValue = [NSString stringWithFormat: @"{\"start\":{\"lat\":%f,\"lon\":%f},\"end\":{\"lat\":%f,\"lon\":%f}}",startCoord.latitude,startCoord.longitude,endCoord.latitude,endCoord.longitude];
#endif
    }
}

-(void)eraseRouteWithIdentifier:(NSString *)identifier{
    GMSPolyline *route = self.routes[identifier];
    route.map = nil;
    [self.routes removeObjectForKey:identifier];
}

-(GMSCoordinateBounds *)boundsForRouteWithIdentifier:(NSString *)identifier{
    GMSPolyline *route = self.routes[identifier];
    if (route) {
        return route.path.spanBounds;
    }
    return nil;
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

+(BOOL)coordinate:(CLLocationCoordinate2D)coordinate isInsidePath:(GMSPath *)path {
    return GMSGeometryContainsLocation(coordinate, path, YES);
}

+(BOOL)coordinate:(CLLocationCoordinate2D)coordinate isInsidePathFromLocations:(NSArray<CLLocation *> *)locations {
    GMSPath *path = [self pathWithLocations:locations];
    return [GMSPath coordinate:coordinate isInsidePath:path];
}

@end

#pragma mark Span

@implementation GMSPath (Span)

-(GMSCoordinateBounds *)spanBounds {
    
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

/**
 * @param locationLiteral should have the format [lng,lat]
 */
+ (CLLocation *)locationFromString:(NSString*)locationLiteral {
    NSArray *locationComponents = [locationLiteral componentsSeparatedByString:@","];
    if (locationComponents.count == 2) {
        double lat = [[locationComponents lastObject] doubleValue];
        double lon = [[locationComponents firstObject] doubleValue];
        return [[CLLocation alloc] initWithLatitude:lat longitude:lon];
    }
    
    return nil;
}

@end
