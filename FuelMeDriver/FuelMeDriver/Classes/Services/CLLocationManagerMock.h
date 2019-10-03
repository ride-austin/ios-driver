//
//  CLLocationManagerMock.h
//  RideDriver
//
//  Created by Roberto Abreu on 8/1/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface CLLocationManagerMock : CLLocationManager

@property (strong, nonatomic) NSDictionary *locationStateMapping;
@property (strong, nonatomic) CLLocation *defaultLocation;

@end
