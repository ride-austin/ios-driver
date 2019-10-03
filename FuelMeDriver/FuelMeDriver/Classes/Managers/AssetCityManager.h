//
//  AssetCityManager.h
//  Ride
//
//  Created by Roberto Abreu on 22/11/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RACity.h"

@interface AssetCityManager : NSObject

+ (UIImage*)defaultSplash;
+ (UIImage*)defaultLogoWhite;
+ (UIImage*)logoImageByCityType:(CityType)cityType;
+ (UIImage*)splashImageByCityType:(CityType)cityType;
+ (UIColor*)colorByCityType:(CityType)cityType andColorType:(CityColorType)colorType;
+ (UIColor*)colorCurrentCity:(CityColorType)colorType;
+ (UIImage*)logoWhiteCurrentCity;
+ (UIImage*)logoImageCurrentCity;
+ (UIImage*)splashImageCurrentCity;

@end
