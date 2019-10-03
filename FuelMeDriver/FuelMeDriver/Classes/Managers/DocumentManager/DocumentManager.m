//
//  DocumentManager.m
//  RideDriver
//
//  Created by Roberto Abreu on 28/11/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "DocumentManager.h"

#import "DocumentManagerDefines.h"
#import "RADriversAPI.h"

NSString *docChauffeurLicense = @"CHAUFFEUR_LICENSE";
NSString *docCarSticker       = @"CAR_STICKER";
NSString *docInsurance        = @"INSURANCE";
NSString *docLicense          = @"LICENSE";

@implementation DocumentManager

#pragma mark - Upload Document

+ (void)uploadChauffeurLicense:(UIImage *)image withExpirationDate:(NSDate *)expirationDate atCityId:(NSNumber *)cityId completion:(void (^)(NSError *))completion {
    [RADriversAPI postDocumentPhoto:image withPhotoType:docChauffeurLicense expirationDate:expirationDate andCarId:nil atCityId:cityId completion:completion];
}

+ (void)uploadInspectionSticker:(UIImage *)image withExpirationDate:(NSDate *)expirationDate atCityId:(NSNumber *)cityId withCarId:(NSString *)carId completion:(DocumentCompletion)completion {
    [RADriversAPI postDocumentPhoto:image withPhotoType:docCarSticker  expirationDate:expirationDate andCarId:carId atCityId:cityId completion:completion];
}

+ (void)uploadInsurancePhoto:(UIImage *)image
          withExpirationDate:(NSDate *)expirationDate
                    forCarId:(NSString*)carId
                    atCityId:(NSNumber *)cityId
                  completion:(DocumentCompletion)completion {
    [RADriversAPI postDocumentPhoto:image
                                         withPhotoType:docInsurance
                                        expirationDate:expirationDate
                                              andCarId:carId
                                              atCityId:cityId
                                            completion:completion];
}

+ (void)uploadLicensePhoto:(UIImage *)image withExpirationDate:(NSDate *)expirationDate atCityId:(NSNumber *)cityId completion:(DocumentCompletion)completion {
    [RADriversAPI postDocumentPhoto:image withPhotoType:docLicense expirationDate:expirationDate andCarId:nil atCityId:cityId completion:completion];
}

#pragma mark - Get Document

+ (void)getChauffeurLicenseWithCompletion:(GetDocumentBlock)completion {
    [RADriversAPI getDocumentWithPhotoType:docChauffeurLicense completion:completion];
}

+ (void)getLicenseWithCompletion:(GetDocumentBlock)completion {
    [RADriversAPI getDocumentWithPhotoType:docLicense completion:completion];
}

+ (void)getInspectionStickerWithCarId:(NSString*)carId completion:(GetDocumentBlock)completion {
    [RADriversAPI getDocumentWithPhotoType:docCarSticker withCarId:carId completion:completion];
}

+ (void)getInsuranceForCarId:(NSString *)carId completion:(GetDocumentBlock)completion {
    [RADriversAPI getDocumentWithPhotoType:docInsurance withCarId:carId completion:completion];
}

#pragma mark - Update Document

+ (void)updateDocument:(RADocument *)document withCompletion:(void(^)(NSError *error))completion {
    [RADriversAPI updateDocument:document withCompletion:completion];
}

#pragma mark - Helper
+ (NSDateFormatter *)displayDateFormatter {
    NSDateFormatter *df = [NSDateFormatter new];
    [df setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
    [df setDateStyle:NSDateFormatterMediumStyle];
    return df;
}

@end
