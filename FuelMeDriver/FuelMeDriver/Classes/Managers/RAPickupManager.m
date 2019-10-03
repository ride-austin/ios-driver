//
//  RAPickupManager.m
//  Ride
//
//  Created by Roberto Abreu on 9/6/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RAPickupManager.h"

#import "ConfigurationManager.h"
#import "RAPickupHint.h"

#import <GoogleMaps/GMSGeometryUtils.h>

@implementation RAPickupManager

+ (BOOL)isLocationInsidePickupHint:(CLLocation *)location {
    return [RAPickupManager pickupHintForLocation:location] != nil;
}

+ (CLLocation *)refinePickupLocation:(CLLocation *)location {
    RADesignatedPickup *designatedPickup = [RAPickupManager nearestDesignatedPickupForLocation:location];
    if (designatedPickup) {
        return designatedPickup.driverCoord.location;
    }
    
    return location;
}

+ (RAPickupHint*)pickupHintForLocation:(CLLocation*)location {
    for (RAPickupHint *pickupHint in [ConfigurationManager shared].global.geocoding.pickupHints) {
        if ([pickupHint containsCoordinate:location.coordinate]) {
            return pickupHint;;
        }
    }
    return nil;
}

+ (RADesignatedPickup *)nearestDesignatedPickupForLocation:(CLLocation*)location {
    RAPickupHint *pickupHint = [RAPickupManager pickupHintForLocation:location];
    RADesignatedPickup *nearestDesignatedPickup;
    for (RADesignatedPickup *designatedPickup in pickupHint.designatedPickups) {
        
        if (!nearestDesignatedPickup) {
            nearestDesignatedPickup = designatedPickup;
            continue;
        }
        
        CLLocationCoordinate2D coordinate = location.coordinate;
        CLLocationDistance distanceCurrentNearestToCoordinate = GMSGeometryDistance(coordinate, nearestDesignatedPickup.driverCoord.location.coordinate);
        CLLocationDistance distanceDesignatedToCoordinate = GMSGeometryDistance(coordinate, designatedPickup.driverCoord.location.coordinate);
        
        if (distanceDesignatedToCoordinate < distanceCurrentNearestToCoordinate) {
            nearestDesignatedPickup = designatedPickup;
        }
    }
    return nearestDesignatedPickup;
}

@end
