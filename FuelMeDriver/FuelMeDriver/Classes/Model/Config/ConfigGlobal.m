//
//  ConfigGlobal.m
//  Ride
//
//  Created by Theodore Gonzalez on 11/26/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "ConfigGlobal.h"

@implementation ConfigGlobal

- (instancetype)init {
    if (self = [super init]) {
        _driverMessages = [ConfigDriverMessages new];
        _commonMessages = [ConfigMessagesCommon new];
        _locationUpdateIntervals = [ConfigLocationUpdateIntervals new];
        _rideAcceptance = [ConfigRideAcceptance new];
    }
    return self;
}

#pragma mark - JSONKeyPaths

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
              @"cancellationFeedback"   : @"cancellationFeedback",
              @"carTypes"               : @"carTypes",
              @"commonMessages"         : @"commonMessages",
              @"currentCity"            : @"currentCity",
              @"directConnectPhone"     : @"directConnectPhone",
              @"driverMessages"         : @"driverMessages",
              @"geocoding"              : @"geocodingConfiguration",
              @"generalInfo"            : @"generalInformation",
              @"locationUpdateIntervals": @"locationUpdateIntervals",
              @"rideAcceptance"         : @"rideAcceptance",
              @"isPhoneMaskingEnabled"  : @"smsMaskingEnabled",
              @"supportedCities"        : @"supportedCities",
              @"womanOnly"              : @"womanOnly",
              @"liveLocation"           : @"riderLiveLocation",
              @"currentTerms"           : @"currentTerms",
              @"configRideUpgrade"      : @"rideUpgrade",
              @"driverTypes"            : @"driverTypes",
              @"shouldShowOnlinePopup"  : @"online.shouldShowPopup",
              @"shouldShowDriverStats"  : @"driverStats.enabled",
              @"configDirectConnect"    : @"directConnect",
              @"driverActions"          : @"driverActions"
            };
}

#pragma mark - Transformers

+ (NSValueTransformer *)cancellationFeedbackJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:ConfigCancellationFeedback.class];
}

+ (NSValueTransformer *)carTypesJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:RACarCategoryDataModel.class];
}

+ (NSValueTransformer *)commonMessagesJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[ConfigMessagesCommon class]];
}

+ (NSValueTransformer *)currentCityJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[RACity class]];
}

+ (NSValueTransformer *)driverMessagesJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[ConfigDriverMessages class]];
}

+ (NSValueTransformer *)generalInfoJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[RAGeneralInfo class]];
}

+ (NSValueTransformer *)geocodingJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[ConfigGeoCoding class]];
}

+ (NSValueTransformer *)locationUpdateIntervalsJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[ConfigLocationUpdateIntervals class]];
}

+ (NSValueTransformer *)rideAcceptanceJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[ConfigRideAcceptance class]];
}

+ (NSValueTransformer *)referDriverJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[ConfigReferFriend class]];
}

+ (NSValueTransformer *)supportedCitiesJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[RACity class]];
}

+ (NSValueTransformer *)womanOnlyJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[ConfigWomanOnly class]];
}

+ (NSValueTransformer *)liveLocationJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[ConfigLiveLocation class]];
}

+ (NSValueTransformer *)currentTermsJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[RATerm class]];
}

+ (NSValueTransformer *)configRideUpgradeJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[ConfigRideUpgrade class]];
}

+ (NSValueTransformer *)driverTypesJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:RADriverType.class];
}
+ (NSValueTransformer *)driverActionsJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[ConfigDriverActions class]];
}

@end

#import "RADriverDataModel.h"
@implementation ConfigGlobal (Helpers)

- (RADriverType *)driverTypeOnlyWomenMode {
    for (RADriverType *driverType in self.driverTypes) {
        if ([driverType.name isEqualToString:@"WOMEN_ONLY"]) {
            return driverType;
        }
    }
    return nil;
}

- (BOOL)availableDCModeForDriver:(RADriverDataModel *)driver {
    ConfigDirectConnect *configDirectConnect = self.configDirectConnect;
    BOOL isChauffeurPermitValid = !configDirectConnect.requiresChauffeur || (configDirectConnect.requiresChauffeur && driver.chauffeurPermit);
    return configDirectConnect.isEnabled && isChauffeurPermitValid;
}

- (BOOL)availableFemaleDriverModeForDriver:(RADriverDataModel *)driver {
    RADriverType *femaleDriverType = self.driverTypeOnlyWomenMode;
    NSArray<NSString*> *grantedDriverTypes = driver.grantedDriverTypes;
    return femaleDriverType && [grantedDriverTypes containsObject:@"WOMEN_ONLY"];
}

@end
