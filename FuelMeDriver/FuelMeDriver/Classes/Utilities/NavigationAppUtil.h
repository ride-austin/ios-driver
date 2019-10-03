//
//  NavigationAppUtil.h
//  RideDriver
//
//  Created by Roberto Abreu on 26/9/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RideDriverEnums.h"

@interface NavigationAppUtil : NSObject

+ (NSString *)nameApp:(NavigationApp)navigationApp;
+ (NSURL *)itunesUrl:(NavigationApp)navigationApp;
+ (NSURL *)urlToOpen:(NavigationApp)navigationApp;
+ (NSURL *)directionURL:(NavigationApp)navigationApp WithDestination:(CLLocation*)destinationLocation;

@end
