//
//  ConfigGlobal.h
//  Ride
//
//  Created by Theodore Gonzalez on 11/26/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "ConfigCancellationFeedback.h"
#import "ConfigDirectConnect.h"
#import "ConfigDriverMessages.h"
#import "ConfigGeoCoding.h"
#import "ConfigLiveLocation.h"
#import "ConfigLocationUpdateIntervals.h"
#import "ConfigMessagesCommon.h"
#import "ConfigReferFriend.h"
#import "ConfigRideAcceptance.h"
#import "ConfigRideUpgrade.h"
#import "ConfigWomanOnly.h"
#import "RACarCategoryDataModel.h"
#import "RACity.h"
#import "RADriverType.h"
#import "RAGeneralInfo.h"
#import "RATerm.h"
#import "ConfigDriverActions.h"

#import <Mantle/Mantle.h>
@class RADriverDataModel;
@interface ConfigGlobal : MTLModel <MTLJSONSerializing>

@property (nonatomic) ConfigCancellationFeedback *cancellationFeedback;
@property (nonatomic) NSArray<RACarCategoryDataModel*> *carTypes;
@property (nonatomic, readonly) ConfigMessagesCommon *commonMessages;
@property (nonatomic) RACity *currentCity;
@property (nonatomic) NSString *directConnectPhone;
@property (nonatomic) ConfigDriverMessages *driverMessages;
@property (nonatomic) RAGeneralInfo *generalInfo;
@property (nonatomic) ConfigGeoCoding *geocoding;
@property (nonatomic, readonly) ConfigLocationUpdateIntervals *locationUpdateIntervals;
@property (nonatomic, readonly) ConfigRideAcceptance *rideAcceptance;
@property (nonatomic) BOOL isPhoneMaskingEnabled;
//@property (nonatomic) ConfigReferFriend *referDriver;
@property (nonatomic) NSArray<RACity *> *supportedCities;
@property (nonatomic) ConfigWomanOnly *womanOnly;
@property (nonatomic) ConfigLiveLocation *liveLocation;
@property (nonatomic) RATerm *currentTerms;
@property (nonatomic) ConfigRideUpgrade *configRideUpgrade;
@property (nonatomic) NSArray<RADriverType*> *driverTypes;
@property (nonatomic) BOOL shouldShowOnlinePopup;
@property (nonatomic) BOOL shouldShowDriverStats;
@property (nonatomic) ConfigDirectConnect *configDirectConnect;
@property (nonatomic) ConfigDriverActions *driverActions;

@end

@interface ConfigGlobal(Helpers)

- (RADriverType *)driverTypeOnlyWomenMode;
- (BOOL)availableDCModeForDriver:(RADriverDataModel *)driver;
- (BOOL)availableFemaleDriverModeForDriver:(RADriverDataModel *)driver;

@end
