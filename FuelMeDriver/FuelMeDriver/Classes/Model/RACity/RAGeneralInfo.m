//
//  RAGeneralInfo.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 11/24/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "RAGeneralInfo.h"

@interface RAGeneralInfo()
@end

@implementation RAGeneralInfo

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
              @"appName"                :@"applicationName",
              @"appNamePipe"            :@"applicationNamePipe",
              @"appstoreLink"           :@"appstoreLink",
              @"companyDomain"          :@"companyDomain",
              @"companyWebsite"         :@"companyWebsite",
              @"facebookUrl"            :@"facebookUrl",
              @"facebookUrlSchemeiOS"   :@"facebookUrlSchemeiOS",
              @"iconURL"                :@"iconUrl",
              @"legalURL"               :@"legal",
              @"logoURL"                :@"logoUrl",
              @"privacyStatementURL"    :@"privacyStatement",
              @"splashURL"              :@"splashUrl",
              @"supportEmail"           :@"supportEmail"
            };
}

+ (NSValueTransformer *)iconURLJSONTransformer:(NSString *)key {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *value, BOOL *success, NSError *__autoreleasing *error) {
        if ([value isKindOfClass:[NSString class]]) {
            return [NSURL URLWithString:value];
        } else {
            return nil;
        }
    }];
}

+ (NSValueTransformer *)logoURLJSONTransformer:(NSString *)key {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *value, BOOL *success, NSError *__autoreleasing *error) {
        if ([value isKindOfClass:[NSString class]]) {
            return [NSURL URLWithString:value];
        } else {
            return nil;
        }
    }];
}

+ (NSValueTransformer *)privacyStatementURLJSONTransformer:(NSString *)key {
    return [MTLJSONAdapter NSURLJSONTransformer];
}

+ (NSValueTransformer *)splashURLJSONTransformer:(NSString *)key {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *value, BOOL *success, NSError *__autoreleasing *error) {
        if ([value isKindOfClass:[NSString class]]) {
            return [NSURL URLWithString:value];
        } else {
            return nil;
        }
    }];
}

- (NSArray<NSURL *> *)urls {
    NSMutableArray *mArray = [NSMutableArray new];
    if (self.iconURL) {
        [mArray addObject:self.iconURL];
    }
    if (self.logoURL) {
        [mArray addObject:self.logoURL];
    }
    if (self.splashURL) {
        [mArray addObject:self.splashURL];
    }
    return mArray;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.appName        = @"Ride Austin";
        self.appstoreLink   = [NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id1116489847"];
        self.companyDomain  = @"RideAustin.com";
        self.companyWebsite = [NSURL URLWithString:@"http://www.rideaustin.com"];
        self.facebookUrl    = [NSURL URLWithString:@"https://www.facebook.com/werideaustin"];
        self.legalURL       = [NSURL URLWithString:@"http://www.rideaustin.com/legal/userterms/"];
        self.privacyStatementURL = [NSURL URLWithString:@"http://www.rideaustin.com/legal/driverprivacystatement/"];
        self.supportEmail   = @"support@rideaustin.com";
    }
    return self;
}

/* SAMPLE DATA DEC 16
 *
generalInformation =     {
    applicationName = "Ride Austin";
    applicationNamePipe = "Ride|Austin";
    appstoreLink = "itms-apps://itunes.apple.com/app/id1116489847";
    companyDomain = "rideaustin.com";
    companyWebsite = "http://www.rideaustin.com";
    facebookUrl = "https://www.facebook.com/werideaustin";
    facebookUrlSchemeiOS = "fb://page?id=241278152906970";
    iconUrl = "https://media.rideaustin.com/images/Ride_180-1.png";
    legal = "http://www.rideaustin.com/legal/userterms/";
    logoUrl = "https://media.rideaustin.com/images/logoRideAustin@3x.jpg";
    playStoreLink = "market://details?id=com.rideaustin.android";
    playStoreWeb = "https://play.google.com/store/apps/details?id=com.rideaustin.android";
    splashUrl = "https://media.rideaustin.com/images/photoAustin@3x.png";
    supportEmail = "support@rideaustin.com";
}
 */
@end
