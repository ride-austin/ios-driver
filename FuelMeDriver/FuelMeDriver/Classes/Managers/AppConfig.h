//
//  AppConfig.h
//  RideDriver
//
//  Created by Roberto Abreu on 2/6/18.
//  Copyright © 2018 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppConfig : NSObject

+ (NSString *)apiKey;
+ (NSString *)hockeyAppId;
+ (NSString *)hockeyAppTestId;
+ (NSString *)googleDirectionsKey;
+ (NSString *)googleMapKey;
+ (NSString *)bugFenderKey;
+ (NSString *)productionServerURL;
+ (NSString *)qaServerURL;
+ (NSString *)stageServerURL;
+ (NSString *)devServerURL;
+ (NSString *)md5PasswordSalt;

@end
