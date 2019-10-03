//
//  GoogleMapsManager.h
//  Ride
//
//  Created by Kitos on 9/8/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <GoogleMaps/GoogleMaps.h>

@interface GoogleMapsManager : NSObject

@property (nonatomic, readonly) GMSMapView * _Nonnull mapView;

-(instancetype _Nonnull)initWithMap:(GMSMapView* _Nonnull)mapView;

@end

@interface GoogleMapsManager (Map)

-(void)setPadding:(UIEdgeInsets)padding;
-(UIEdgeInsets)getPadding;
-(CLLocation* _Nullable)getMyCurrentLocation;

@end

@interface GoogleMapsManager (Markers)

-(void)addMarkerToCoordinates:(CLLocationCoordinate2D)coords withIdentifier:( NSString* _Nonnull) identifier icon:(UIImage* _Nullable)icon;
-(void)addMarker:(GMSMarker* _Nonnull)marker withIdentifier:( NSString* _Nonnull) identifier toCoordinates:(CLLocationCoordinate2D)coords;
-(void)removeMarkerWithIdentifier:(NSString* _Nonnull) identifier;

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

-(void)drawRoute:(GMSPolyline* _Nonnull)route withIdentifier:(NSString* _Nonnull)identifier;
-(void)eraseRoutWithIdentifier:(NSString* _Nonnull)identifier;

-(GMSCoordinateBounds * _Nullable)boundsForRouteWithIdentifier:(NSString* _Nonnull)identifier;

@end

@interface GMSPolyline (Span)

-(GMSCoordinateBounds* _Nonnull)bounds;

@end

@interface GMSPath (Utils)

+(GMSPath* _Nonnull)pathWithLocations:(NSArray<CLLocation*> * _Nonnull)locations;
+(BOOL) location:(CLLocation* _Nonnull)location isInsidePath:(GMSPath* _Nonnull)path;
+(BOOL) location:(CLLocation* _Nonnull)location isInsidePathFromLocations:(NSArray<CLLocation*> * _Nonnull)locations;

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

@end
