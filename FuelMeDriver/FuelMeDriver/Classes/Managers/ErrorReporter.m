//
//  ErrorReporter.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 9/6/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "ErrorReporter.h"

#import "RideDriverConstants.h"
#import "RAEnvironmentManager.h"

@implementation ErrorReporter

+ (NSError *)recordErrorDomainName:(ERDomain)erDomainName withInvalidResponse:(id)response {
    NSMutableDictionary *mDict = [NSMutableDictionary new];
    if (!response) {
        mDict[@"response"] = @"nil";
    } else if ([response isKindOfClass:[NSNull class]]) {
        mDict[@"response"] = @"NSNull";
    } else {
        mDict[@"response"] = response;
    }
    return [self recordErrorDomainName:erDomainName withUserInfo:mDict];
}

+ (NSError *)recordErrorDomainName:(ERDomain)erDomainName withUserInfo:(NSDictionary *)userInfo {
    NSString *domainName   = [ErrorReporter stringForDomainName:erDomainName];
    NSString *version      = [NSString stringWithFormat:@"V%@",[RAEnvironmentManager sharedManager].version];
    NSString *errorMessage = [NSString stringWithFormat:@"%@ %@", domainName, version];
    
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithDictionary:userInfo];
    [mDict addEntriesFromDictionary:@{NSLocalizedRecoverySuggestionErrorKey : errorMessage}];
    
    NSError *error = [NSError errorWithDomain:domainName code:erDomainName userInfo:mDict];
    [self recordError:error withDomainName:erDomainName];
    return error;
}

+ (void)recordError:(NSError *)error withDomainName:(ERDomain)erDomainName {
    [self recordError:error withDomainName:erDomainName andCustomName:nil];
}

+ (void)recordError:(NSError *)error withDomainName:(ERDomain)erDomainName andCustomName:(NSString *)customDomainName {
    BOOL hasValidError = [error isKindOfClass:[NSError class]];
    if (hasValidError && [self shouldRecordError:error forDomain:erDomainName]) {
        NSString *domainName = [self stringForDomainName:erDomainName];
        if ([customDomainName isKindOfClass:[NSString class]]) {
            domainName = customDomainName;
        }
        NSError *newError = [NSError errorWithDomain:domainName code:error.code userInfo:error.userInfo];
        [CrashlyticsKit recordError:newError];
    }
}

+ (NSString *)stringForDomainName:(ERDomain)erDomainName {
    switch (erDomainName) {
        case GETDriver:                            return @"GETDriver";
        case GETPromoCode:                         return @"GETPromoCode";
        case GETDiscount:                          return @"GETDiscount";
        case GETCar:                               return @"GETCar";
        case GETActiveDrivers:                     return @"GETActiveDrivers";
        case GETEvents:                            return @"GETEvents";
        case GETRideByID:                          return @"GETRideByID";
        case GETRideByIDInvalidResponse:           return @"GETRideByIDInvalidResponse";
        case GETEarningsRides:                     return @"GETEarningsRides";
        case GETEarningsRidesInvalidResponse:      return @"GETEarningsRidesInvalidResponse";
        case GETEarningsTimeOnline:                return @"GETEarningsTimeOnline";
        case GETEarningsTimeOnlineInvalidResponse: return @"GETEarningsTimeOnlineInvalidResponse";
        case GETRideMapURL:                        return @"GETRideMapURL";
        case GETRideMapURLInvalidRideID:           return @"GETRideMapURLInvalidRideID";
        case GETRideMapURLInvalidResponse:         return @"GETRideMapURLInvalidResponse";
        case GETQueues:                            return @"GETQueues";
        case GETQueuesInvalidResponse:             return @"GETQueuesInvalidResponse";
        case GETQueuePosition:                     return @"GETQueuePosition";
        case GETQueuePositionInvalidResponse:      return @"GETQueuePositionInvalidResponse";
        case GETSurgePricing:                      return @"GETSurgePricing";
        case GETSurgePricingInvalidResponse:       return @"GETSurgePricingInvalidResponse";
        case GETSurgeAreas:                        return @"GETSurgeAreas";
        case GETSurgeAreasInvalidResponse:         return @"GETSurgeAreasInvalidResponse";
        case GETAvailableCarTypes:                 return @"GETAvailableCarTypes";
        case GETacdrCurrent:                       return @"GETacdrCurrent";
        case GETacdrStuck:                         return @"GETacdrStuck";
        case GETRidesCurrentNoRide:                return @"GETRidesCurrentNoRide";
        case GETCarCategories:                     return @"GETCarCategories";
        case GETDriverTypes:                       return @"GETDriverTypes";
        case GETCurrentUser:                       return @"GETCurrentUser";
        case GETGlobalConfiguration:               return @"GETGlobalConfiguration";
        case GETCarPhotos:                         return @"GETCarPhotos";
        case GETGlobalConfigurationInvalidData:    return @"GETGlobalConfigurationInvalidData";
        case GETAllCars:                           return @"GETAllCars";
        case GETAllCarsInvalidResponse:            return @"GETAllCarsInvalidResponse";
        case GETDriverFile:                        return @"GETDriverFile";
        case GETCityDetail:                        return @"GETCityDetail";
        case GETDriverCarFile:                     return @"GETDriverCarFile";
        case GETDriverCarsNoneSelected:            return @"GETDriverCarsNoneSelected";
        case GETDriverTerms:                       return @"GETDriverTerms";
            
        case POSTImage:                            return @"POSTImage";
        case POSTImageInvalidImage:                return @"POSTImageInvalidImage";
        case POSTCreateUser:                       return @"POSTCreateUser";
        case POSTLogin:                            return @"POSTLogin";
        case POSTGoOnline:                         return @"POSTGoOnline";
        case POSTAcceptRide:                       return @"POSTAcceptRide";
        case POSTStartRide:                        return @"POSTStartRide";
        case POSTEndRide:                          return @"POSTEndRide";
        case POSTLocationBatchUpdate:              return @"POSTLocationBatchUpdate";
        case POSTIsUserNameAvailable:              return @"POSTIsUserNameAvailable";
        case POSTFacebookRegister:                 return @"POSTFacebookRegister";
        case POSTSupport:                          return @"POSTSupport";
        case POSTReferAFriend:                     return @"POSTReferAFriend";
        case POSTDeclineRide:                      return @"POSTDeclineRide";
        case POSTPhoneVerificationRequest:         return @"POSTPhoneVerificationRequest";
        case POSTPhoneVerificationSubmit:          return @"POSTPhoneVerificationSubmit";
        case POSTMaskCall:                         return @"POSTMaskCall";
        case POSTMaskSMS:                          return @"POSTMaskSMS";
        case POSTSMSInvalidRideID:                 return @"POSTSMSInvalidRideID";
        case POSTMaskCallInvalidRideID:            return @"POSTMaskCallInvalidRideID";
        case POSTCarInformation:                   return @"POSTCarInformation";
        case POSTRidesEvents:                      return @"POSTRidesEvents";
        case POSTRidesReceived:                    return @"POSTRidesReceived";
            
        case PUTLocationUpdate:                    return @"PUTLocationUpdate";
        case PUTRateRide:                          return @"PUTRateRide";
        case PUTRateRideInvalidRideID:             return @"PUTRateRideInvalidRideID";
        case PUTSaveProfile:                       return @"PUTSaveProfile";
        case PUTSelectCar:                         return @"PUTSelectCar";
        case PUTUpdateCar:                         return @"PUTUpdateCar";
        case PUTDriver:                            return @"PUTDriver";
        case PUTDocuments:                         return @"PUTDocuments";
        case PUTAcceptDriverTerms:                 return @"PUTAcceptDriverTerms";
            
        case DELETEGoOffline:                      return @"DELETEGoOffline";
        case DELETERideByID:                       return @"DELETERideByID";
        case DELETECarPhoto:                       return @"DeleteCarPhoto";
            
        case GOOGLEReverseGeocode:                 return @"GOOGLEReverseGeocode";
        case GOOGLEZipBoundaries:                  return @"GOOGLEZipBoundaries";
        case GOOGLEGetRoute:                       return @"GOOGLEGetRoute";
        case GOOGLEAutoComplete:                   return @"GOOGLEAutoComplete";
        case APPLEReverseGeoCode:                  return @"APPLEReverseGeoCode";
            
        case FBLogin:                              return @"FBLogin";
        case FBGraph:                              return @"FBGraph";
        case LoadCarsData:                         return @"LoadCarsData";
        case LoadConfigData:                       return @"LoadConfigData";
            
        case CKEndCall:                            return @"CKEndCall";
        case CKStartCall:                          return @"CKStartCall";
        case SoundFileNotFound:                    return @"SoundFileNotFound";
        case SoundPlayerFailed:                    return @"SoundPlayerFailed";
        
        case InvalidJSONRidesCurrent:              return @"InvalidJSONRidesCurrent";
        case InvalidJSONRidesEnd:                  return @"InvalidJSONRidesEnd";
        case InvalidJSONRidesSpecific:             return @"InvalidJSONRidesSpecific";
            
        case UIRootNavigationControllerReplaced:   return @"UIRootNavigationControllerReplaced";
            
        case SERVERConnectionUnavailable:          return @"SERVERConnectionUnavailable";

        case SERVERNetworkConnectionLost:          return @"ServerNetworkConnectionLost";
        case SERVERUnavailable:                    return @"ServerUnavailable";
        
        case WATCHDrawRouteFailed:                 return @"WATCHDrawRouteFailed";
        case WATCHrequestReceivedWhileOnTrip:      return @"WATCHrequestReceivedWhileOnTrip";
        case WATCHinvalidAccuracyTooLow:           return @"WATCHinvalidAccuracyTooLow";
        case WATCHQEventsMissingParameter:         return @"WATCHQEventsMissingParameter";
        case WATCHPickupLocation:                  return @"WATCHPickupLocation";
        case WATCHRideTypeInvalidClass:            return @"WATCHRideTypeInvalidClass";
    }
}

+(BOOL)shouldRecordError:(NSError *)error forDomain:(ERDomain)erDomainName {
    //
    //  COMMON ERRORS
    //
    NSNumber *isCommonError = [self shouldRecordAsCommonError:error];
    if (isCommonError != nil) {
        return isCommonError.boolValue;
    };
    
    //
    //  SPECIFIC ERRORS
    //
    switch (erDomainName) {
        case GETEvents:
            // The request timed out.
            if (error.code == -1001) return NO;
        case PUTLocationUpdate:
            // RA-822
            if (error.code == 400 ||
                error.code == 409 ||
                error.code == 500) return NO;
        default:
            return YES;
    }
    return YES;
}

/**
 *  return nil if not a common error
 *  return @(NO)  will avoid reporting
 *  return @(YES) will be reported as common error
 */
+ (NSNumber *)shouldRecordAsCommonError:(NSError *)error {
    BOOL noInternet = [@"The network connection was lost." isEqualToString:error.localizedDescription];
    switch (error.code) {
        case 0:
            if (noInternet) return @(NO);
        case -1005: //no internet
        case -1009:
            return @(NO);
        case -1003: //A server with the specified hostname could not be found.
        case -1011: //this issue happens when server is overloaded, and it affects a lot of requests
        case -1019: //a data connection cannot be established since a call is currently active.
        case -1020: //A data connection is not currently allowed.
        case -1200: //An SSL error has occurred and a secure connection to the server cannot be made.
            return @(YES);
        default:
            return nil;
    }
}

/**
 *  return NO ~ error wasn't handled
 *  return YES ~ error reported and notified
 */
+ (BOOL)reportConnectivityError:(NSError*)error {
    DBLog(@"Error: [%d] %@", (int)error.code, error.localizedDescription);
    
    if (![ErrorReporter shouldHandleConnectivityError:error]) {
        return NO;
    }
    
    switch (error.code) {
        case NSURLErrorCannotConnectToHost:
        case NSURLErrorNetworkConnectionLost:
        case SERVERUnavailable:
            [ErrorReporter recordError:error withDomainName:error.code];
            DBLog(@"Server Connectivity Lost (code: %ld)", (long)error.code);
            break;
            
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNetworkConnectivityLost
                                                        object:nil
                                                      userInfo:nil];
    return YES;
}

+ (BOOL)shouldHandleConnectivityError:(NSError*)error {
    return (error.code == SERVERConnectionUnavailable) || (error.code == SERVERNetworkConnectionLost) || (error.code == SERVERUnavailable);
}

@end
