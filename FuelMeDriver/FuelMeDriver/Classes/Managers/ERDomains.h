//
//  ERDomains.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 9/6/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#ifndef ERDomains_h
#define ERDomains_h
#endif /* ERDomains_h */
/**
 *  @brief GET, POST, PUT, DELETE for request types
 *  
 *  FB, GOOGLE, APPLE for third party APIs
 *
 *  UI for unexpected UI issue
 *
 *  WATCH for observing fixes for issues that are reported but cannot be easily reproduced
 */
typedef NS_ENUM(NSInteger, ERDomain) {
    GETDriver                           = -100,
    GETPromoCode                        = -101,
    GETDiscount                         = -102,
    GETCar                              = -103,
    GETActiveDrivers                    = -104,
    GETEvents                           = -105,
    GETRideByID                         = -107,
    GETRideByIDInvalidResponse          = -108,
    GETEarningsRides                    = -109,
    GETEarningsRidesInvalidResponse     = -110,
    GETEarningsTimeOnline               = -111,
    GETEarningsTimeOnlineInvalidResponse= -112,
    GETRideMapURL                       = -114,
    GETRideMapURLInvalidRideID          = -115,
    GETRideMapURLInvalidResponse        = -116,
    GETQueuePosition                    = -117,
    GETQueuePositionInvalidResponse     = -118,
    GETSurgePricing                     = -119,
    GETSurgePricingInvalidResponse      = -120,
    GETSurgeAreas                       = -121,
    GETSurgeAreasInvalidResponse        = -122,
    GETAvailableCarTypes                = -123,
    GETacdrCurrent                      = -124,
    GETQueues                           = -126,
    GETQueuesInvalidResponse            = -127,
    GETDriverTypes                      = -128,
    GETCarCategories                    = -129,
    GETCurrentUser                      = -130,
    GETAllCars                          = -131,
    GETAllCarsInvalidResponse           = -132,
    GETCarPhotos                        = -134,
    GETDriverTerms                      = -135,
    GETacdrStuck                        = -192,
    GETRidesCurrentNoRide               = -193,
    GETDriverCarsNoneSelected           = -194,
    GETDriverCarFile                    = -195,
    GETCityDetail                       = -196,
    GETDriverFile                       = -197,
    GETGlobalConfigurationInvalidData   = -198,
    GETGlobalConfiguration              = -199,
    
    POSTImage                           = -200,
    POSTImageInvalidImage               = -201,
    POSTCreateUser                      = -202,
    POSTLogin                           = -203,
    POSTAcceptRide                      = -204,
    POSTStartRide                       = -205,
    POSTEndRide                         = -206,
    POSTLocationBatchUpdate             = -207,
    POSTIsUserNameAvailable             = -208,
    POSTFacebookRegister                = -209,
    POSTSupport                         = -210,
    POSTReferAFriend                    = -211,
    POSTDeclineRide                     = -212,
    POSTGoOnline                        = -213,
    POSTPhoneVerificationRequest        = -218,
    POSTPhoneVerificationSubmit         = -219,
    POSTMaskCall                        = -220,
    POSTMaskSMS                         = -221,
    POSTSMSInvalidRideID                = -222,
    POSTMaskCallInvalidRideID           = -223,
    POSTCarInformation                  = -224,
    POSTRidesEvents                     = -225,
    POSTRidesReceived                   = -227,
    
    PUTLocationUpdate                   = -300,
    PUTRateRide                         = -301,
    PUTRateRideInvalidRideID            = -302,
    PUTSaveProfile                      = -303,
    PUTSelectCar                        = -304,
    PUTUpdateCar                        = -305,
    PUTDriver                           = -306,
    PUTDocuments                        = -307,
    PUTAcceptDriverTerms                = -308,
    
    DELETEGoOffline                     = -400,
    DELETERideByID                      = -401,
    DELETECarPhoto                      = -402,
    
    GOOGLEReverseGeocode                = -500,
    GOOGLEZipBoundaries                 = -501,
    GOOGLEGetRoute                      = -502,
    GOOGLEAutoComplete                  = -503,
    APPLEReverseGeoCode                 = -550,
    
    FBLogin                             = -600,
    FBGraph                             = -601,
    LoadCarsData                        = -603,
    LoadConfigData                      = -604,
    
    CKEndCall                           = -700,
    CKStartCall                         = -701,
    
    SoundFileNotFound                   = -702,
    SoundPlayerFailed                   = -703,
    
    InvalidJSONRidesCurrent             = -801,
    InvalidJSONRidesEnd                 = -802,
    InvalidJSONRidesSpecific            = -803,
    
    UIRootNavigationControllerReplaced  = -999,
    
    SERVERConnectionUnavailable         = -1004, //NSURLErrorCannotConnectToHost
    SERVERNetworkConnectionLost         = -1005, //NSURLErrorNetworkConnectionLost
    SERVERUnavailable                   = 503,
    
    WATCHrequestReceivedWhileOnTrip     = -2352,
    WATCHDrawRouteFailed                = -2707,
    WATCHinvalidAccuracyTooLow          = -1645,
    WATCHQEventsMissingParameter        = -4081,
    WATCHPickupLocation                 = -4736,
    WATCHRideTypeInvalidClass           = -4609
};
