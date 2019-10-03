//
//  NavigationAppUtil.m
//  RideDriver
//
//  Created by Roberto Abreu on 26/9/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "NavigationAppUtil.h"

#import "ConfigurationManager.h"
#import "LocationService.h"

@implementation NavigationAppUtil

+ (NSString *)nameApp:(NavigationApp)navigationApp{
    NSString *name = @"";
    switch (navigationApp) {
        case WazeApp:
            name = @"Waze";
            break;
        case GoogleMapApp:
            name = @"Google Maps";
            break;
        case AppleMaps:
            name = @"Apple Maps";
            break;
        default:
            break;
    }
    return name;
}

+ (NSURL *)itunesUrl:(NavigationApp)navigationApp{
    NSURL *url = nil;
    switch (navigationApp) {
        case WazeApp:
            url = [NSURL URLWithString:@"itms://itunes.apple.com/us/app/waze-social-gps-traffic/id323229106?mt=8"];
            break;
        case GoogleMapApp:
            url = [NSURL URLWithString:@"itms://itunes.apple.com/us/app/google-maps-real-time-navigation/id585027354?mt=8"];
        default:
            break;
    }
    return url;
}


+ (NSURL *)urlToOpen:(NavigationApp)navigationApp{
    NSURL *url = nil;
    switch (navigationApp) {
        case WazeApp:
            url = [NSURL URLWithString:@"waze://"];
            break;
        case GoogleMapApp:
            url = [NSURL URLWithString:@"comgooglemaps-x-callback://"];
            break;
        case AppleMaps:
            url = [NSURL URLWithString:@"http://maps.apple.com"];
        default:
            break;
    }
    return url;
}

+ (NSURL *)directionURL:(NavigationApp)navigationApp WithDestination:(CLLocation*)destinationLocation{
    NSURL *url = nil;
    NSString *destinationString = [NSString stringWithFormat:@"%f,%f", destinationLocation.coordinate.latitude,destinationLocation.coordinate.longitude];
    
    switch (navigationApp) {
        case WazeApp:
            url = [NSURL URLWithString:[NSString stringWithFormat:@"waze://?ll=%@&navigate=yes&z=25", destinationString]];
            break;
        case GoogleMapApp:
            url = [NSURL URLWithString:[NSString stringWithFormat: @"comgooglemaps-x-callback://?daddr=%@&directionsmode=driving&x-success=sourceapp://?resume=true&x-source=%@",destinationString,[ConfigurationManager localAppName]]];
            break;
        case AppleMaps:
            url = [NSURL URLWithString:[NSString stringWithFormat: @"http://maps.apple.com/?daddr=%@&dirflg=d", destinationString]];
            break;
        default:
            break;
    }
    
    DBLog(@"URL: %@", url);
    
    return url;
}

@end
