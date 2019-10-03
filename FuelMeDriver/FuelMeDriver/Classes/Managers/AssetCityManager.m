//
//  AssetCityManager.m
//  Ride
//
//  Created by Roberto Abreu on 22/11/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "AssetCityManager.h"

#import "ConfigurationManager.h"
#import "UIColor+HexUtils.h"

@implementation AssetCityManager

+ (UIImage *)defaultSplash {
    return [UIImage imageNamed:@"splashAustin"];
}

+ (UIImage *)defaultLogoWhite {
    return [UIImage imageNamed:@"logoRideAustin_white"];
}

+ (UIImage *)logoWhiteByCityType:(CityType)cityType {
    switch (cityType) {
        case Houston:
            return [UIImage imageNamed:@"logoRideHouston_white"];
        case Austin:
        default:
            return [UIImage imageNamed:@"logoRideAustin_white"];
    }
}

+ (UIImage *)logoImageByCityType:(CityType)cityType{
    switch (cityType) {
        case Houston:
            return [UIImage imageNamed:@"logoRideHouston"];
        case Austin:
        default:
            return [UIImage imageNamed:@"logoRideAustin"];
            break;
    }
    NSString* logo = [NSString stringWithFormat:@"logoRide%@", [AssetCityManager cityNameByCityType:cityType]];
    DBLog(@"LOGO: %@", logo);
    return [UIImage imageNamed:logo];
}

+ (UIImage *)splashImageByCityType:(CityType)cityType{
    NSString* splash = [NSString stringWithFormat:@"splash%@", [AssetCityManager cityNameByCityType:cityType]];
    DBLog(@"SPLASH: %@", splash);
    return [UIImage imageNamed:splash];
}

+ (UIColor *)colorByCityType:(CityType)cityType andColorType:(CityColorType)colorType{
    switch (cityType) {
        case Houston:
            switch (colorType) {
                case Foreground:    return [UIColor whiteColor];
                case Background:    return [UIColor colorWithHex:@"#02A7F9"];
                case SecondaryText: return [UIColor colorWithHex:@"#02A7F9"];
                case SecondaryBack: return [UIColor whiteColor];
                case Border:        return [UIColor colorWithHex:@"#02A7F9"];
            }
            break;
        case Austin:
        default:
            switch (colorType) {
                case Foreground:    return [UIColor whiteColor];
                case Background:    return [UIColor colorWithHex:@"#02A7F9"];
                case SecondaryText: return [UIColor colorWithHex:@"#02A7F9"];
                case SecondaryBack: return [UIColor whiteColor];
                case Border:        return [UIColor colorWithHex:@"#02A7F9"];
            }
    }
    return [UIColor clearColor];
}

+ (UIColor *)colorCurrentCity:(CityColorType)colorType {
    return [AssetCityManager colorByCityType:[ConfigurationManager getCurrentCityType] andColorType:colorType];
}

+ (UIImage *)logoWhiteCurrentCity {
    return [AssetCityManager logoWhiteByCityType:[ConfigurationManager getCurrentCityType]];
}

+ (UIImage *)logoImageCurrentCity {
    return [AssetCityManager logoImageByCityType:[ConfigurationManager getCurrentCityType]];
}

+ (UIImage *)splashImageCurrentCity {
    return [AssetCityManager splashImageByCityType:[ConfigurationManager getCurrentCityType]];
}

+ (NSString *)cityNameByCityType:(CityType)cityType {
    switch (cityType) {
        case Austin:
            return @"Austin";
        case Houston:
            return @"Houston";
        default:
            return nil;
    }
}

@end
