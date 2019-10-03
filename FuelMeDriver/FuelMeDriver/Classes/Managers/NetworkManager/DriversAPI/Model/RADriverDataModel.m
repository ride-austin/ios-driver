//
//  RADriverDataModel.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 8/30/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RADriverDataModel.h"

@implementation RADriverDataModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return
    @{
      @"modelID" : @"id",
      @"directConnectId" : @"directConnectId",
      @"user" : @"user",
      @"active" : @"active",
      @"agreementDate" : @"agreementDate", 
      @"ssn" : @"ssn",
      @"licenseNumber" : @"licenseNumber",
      @"licensePictureUrl" : @"licensePictureUrl",
      @"licenseExpiryDate" : @"licenseExpiryDate", 
      @"licenseState" : @"licenseState",
      @"cars" : @"cars",
      @"rating" : @"rating",
      @"payoneerId" : @"payoneerId",
      @"payoneerStatus" : @"payoneerStatus",
      @"payoneerSignupUrl" : @"payoneerSignupUrl",
      @"checkrStatus" : @"checkrStatus",
      @"photoUrl" : @"photoUrl",
      @"activationDate" : @"activationDate",
      @"agreedToLegalTerms" : @"agreedToLegalTerms",
      @"fingerprintCleared" : @"fingerprintCleared",
      @"cityApprovalStatus" : @"cityApprovalStatus",
      @"activationStatus" : @"activationStatus",
      @"activationNotes" : @"activationNotes",
      @"onboardingStatus" : @"onboardingStatus",
      @"onboardingPendingSince" : @"onboardingPendingSince",
      @"grantedDriverTypes" : @"grantedDriverTypes",
      @"cityId" : @"cityId",
      @"enabledRequestTypes" : @"enabledRequestTypes",
      @"type" : @"type",
      @"email" : @"email",
      @"gender" : @"gender",
      @"firstname" : @"firstname",
      @"lastname" : @"lastname",
      @"phoneNumber" : @"phoneNumber",
      @"fullName" : @"fullName",
      @"checkrReports" : @"checkrReports",
      @"chauffeurPermit" : @"chauffeurPermit"
      };
}

+ (NSValueTransformer *)userJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        return [MTLJSONAdapter modelOfClass:RAUserDataModel.class fromJSONDictionary:value error:error];
    } reverseBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        return [MTLJSONAdapter JSONDictionaryFromModel:value error:error];
    }];
}

+ (NSValueTransformer *)carsJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        return [MTLJSONAdapter modelsOfClass:Car.class fromJSONArray:value error:error];
    } reverseBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        return [MTLJSONAdapter JSONArrayFromModels:value error:error];
    }];
}

#pragma mark -

- (Car *)selectedCar {
    for (Car *car in self.cars) {
        if (car.isSelected) {
            return car;
        }
    }
    return nil;
}

@end

@implementation RADriverDataModel (UnitTests)

- (void)updateChauffeurPermit:(BOOL)hasChauffeurPermit {
    _chauffeurPermit = hasChauffeurPermit;
}
@end
