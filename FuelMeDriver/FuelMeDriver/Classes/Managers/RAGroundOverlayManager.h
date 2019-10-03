//
//  RAGroundOverlayManager.h
//  RideDriver
//
//  Created by Roberto Abreu on 9/13/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GMSMapView;

typedef void(^GroundOverlayBlock)(UIImage *image);

@interface RAGroundOverlayManager : NSObject

+ (void)groundOverlayForLocations:(NSArray<CLLocation*> *)locations mapView:(GMSMapView*)mapView completion:(GroundOverlayBlock)completion;

@end
