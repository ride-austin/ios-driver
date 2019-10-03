//
//  GoogleMapsManager.h
//  RideAustin
//
//  Created by Kitos on 9/8/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <GoogleMaps/GoogleMaps.h>

@interface GoogleMapsManager : NSObject

@property (nonatomic, readonly) GMSMapView * _Nonnull mapView;

- (instancetype _Nonnull)initWithMap:(GMSMapView* _Nonnull)mapView;

@end

@interface GoogleMapsManager (Map)

- (void)configureMapViewWithBlock:(void(^_Nonnull)(GMSMapView* _Nonnull mapView))configurationBlock;
- (void)setPadding:(UIEdgeInsets)padding;
- (UIEdgeInsets)getPadding;

@end

@interface GoogleMapsManager (Markers)

-(void)addMarkerToCoordinates:(CLLocationCoordinate2D)coords withIdentifier:(NSString* _Nonnull)identifier icon:(UIImage* _Nullable)icon zIndex:(int)zIndex andRotation:(CLLocationDegrees)rotation;
-(void)addMarkerToCoordinates:(CLLocationCoordinate2D)coords withIdentifier:(NSString* _Nonnull)identifier icon:(UIImage* _Nullable)icon zIndex:(int)zIndex;
-(void)addMarkerToCoordinates:(CLLocationCoordinate2D)coords withIdentifier:( NSString* _Nonnull)identifier icon:(UIImage* _Nullable)icon;
-(void)addMarker:(GMSMarker* _Nonnull)marker withIdentifier:(NSString* _Nonnull)identifier toCoordinates:(CLLocationCoordinate2D)coords;
-(void)updateMarkerWithIdentifier:(NSString* _Nonnull)identifier toPosition:(CLLocationCoordinate2D)coords;
-(void)removeMarkerWithIdentifier:(NSString* _Nonnull)identifier;
-(GMSMarker* _Nullable)markerWithIdentifier:(NSString* _Nonnull)identifier;

@end

@interface GoogleMapsManager (Camera)

-(void)animateToLocation:(CLLocationCoordinate2D)coordinate;
-(void)animateToZoom:(float)zoom;
-(void)animateCameraToCoordinate:(CLLocationCoordinate2D)coordinate;
-(void)animateCameraToCoordinate:(CLLocationCoordinate2D)coordinate zoom:(float)zoomLevel;
-(void)animateCameraToFitStartCoordinate:(CLLocationCoordinate2D)start endCoordinate:(CLLocationCoordinate2D)end withEdgeInsets:(UIEdgeInsets)insets;
-(void)animateCameraToFitBounds:(GMSCoordinateBounds* _Nonnull)bounds withEdgeInsets:(UIEdgeInsets)insets;

@end

@interface GoogleMapsManager (Route)

-(void)getRouteFrom:(CLLocationCoordinate2D)from to:(CLLocationCoordinate2D)to completion:( void (^ _Nullable)(GMSPolyline* _Nullable polyline, GMSCoordinateBounds* _Nullable bounds, NSError* _Nullable error) )handler;
-(GMSPolyline* _Nullable)routeWithIdentifier:(NSString* _Nonnull)identifier;
-(void)drawRoute:(GMSPolyline* _Nonnull)route withIdentifier:(NSString* _Nonnull)identifier;
-(void)updateRoutePathWithIdentifier:(NSString* _Nonnull)identifier andPath:(GMSPath* _Nonnull)path;
-(void)eraseRouteWithIdentifier:(NSString* _Nonnull)identifier;

-(GMSCoordinateBounds * _Nullable)boundsForRouteWithIdentifier:(NSString* _Nonnull)identifier;

@end



@interface GMSPath (Utils)

+(GMSPath* _Nonnull)pathWithLocations:(NSArray<CLLocation*> * _Nonnull)locations;
+(BOOL)location:(CLLocation* _Nonnull)location isInsidePath:(GMSPath* _Nonnull)path;
+(BOOL)location:(CLLocation* _Nonnull)location isInsidePathFromLocations:(NSArray<CLLocation*> * _Nonnull)locations;
+(BOOL)coordinate:(CLLocationCoordinate2D)coordinate isInsidePath:(GMSPath *_Nonnull)path;
+(BOOL)coordinate:(CLLocationCoordinate2D)coordinate isInsidePathFromLocations:(NSArray<CLLocation *> *_Nonnull)locations;

@end

@interface CLLocation (Validation)

-(BOOL)isValid;

@end

@interface CLLocation (Equality)
/**
 *  @brief compares values as sent to server, 6 decimal place precision, not more
 */
-(BOOL)isEqualToOtherLocation:(CLLocation* _Nonnull)otherLocation; //Only comparing coordinate

@end

@interface CLLocation (Utils)

-(CLLocationDegrees)getHeadingToOtherCoordinate:(CLLocationCoordinate2D)otherCoord;
-(CLLocationCoordinate2D)coordinateWithBearing:(CLLocationDegrees)bearing andDistance:(CLLocationDistance)meters;
/**
 *  @brief returns a coordinate diametrally opposite to the given coordinate.
 */
-(CLLocationCoordinate2D)coordinateOppositeToOtherCoordinate:(CLLocationCoordinate2D)otherCoordinate;

-(CLLocationCoordinate2D)middleCoordinateToOtherCoordinate:(CLLocationCoordinate2D)otherCoordinate;

/**
 * @param locationLiteral should have the format [lng,lat]
 */
+(CLLocation * _Nullable)locationFromString:(NSString* _Nonnull)locationLiteral;

@end
