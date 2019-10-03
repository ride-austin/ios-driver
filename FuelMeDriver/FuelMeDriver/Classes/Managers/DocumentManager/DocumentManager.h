//
//  DocumentManager.h
//  RideDriver
//
//  Created by Roberto Abreu on 28/11/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NetworkManager.h"
#import "RADocument.h"

@interface DocumentManager : NSObject

#pragma mark - Upload Document

+ (void)uploadChauffeurLicense:(UIImage *)image
   withExpirationDate:(NSDate *)expirationDate
             atCityId:(NSNumber *)cityId
           completion:(void (^)(NSError *error))completion;

+ (void)uploadInspectionSticker:(UIImage*)image
             withExpirationDate:(NSDate *)expirationDate
                       atCityId:(NSNumber*)cityId
                      withCarId:(NSString*)carId
                     completion:(DocumentCompletion)completion;

+ (void)uploadInsurancePhoto:(UIImage*)image
          withExpirationDate:(NSDate *)expirationDate
                    forCarId:(NSString*)cardId
                    atCityId:(NSNumber *)cityId
                  completion:(DocumentCompletion)completion;

+ (void)uploadLicensePhoto:(UIImage *)image
        withExpirationDate:(NSDate *)expirationDate
                  atCityId:(NSNumber *)cityId
                completion:(DocumentCompletion)completion;

#pragma mark - Get Document

+ (void)getChauffeurLicenseWithCompletion:(GetDocumentBlock)completion;
+ (void)getLicenseWithCompletion:(GetDocumentBlock)completion;

+ (void)getInspectionStickerWithCarId:(NSString*)carId
                           completion:(GetDocumentBlock)completion;
+ (void)getInsuranceForCarId:(NSString *)carId
                   completion:(GetDocumentBlock)completion;

#pragma mark - Update Document

+ (void)updateDocument:(RADocument *)document withCompletion:(void(^)(NSError *error))completion;

#pragma mark - Helper
+ (NSDateFormatter *)displayDateFormatter;

@end
