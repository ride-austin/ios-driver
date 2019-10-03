//
//  RADriverDataModel.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 8/30/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "Car.h"
#import "RABaseDataModel.h"
#import "RAUserDataModel.h"

@interface RADriverDataModel : RABaseDataModel

@property (nonatomic, readwrite) RAUserDataModel *user;
@property (nonatomic, readwrite) NSString *directConnectId;
@property (nonatomic, readonly) BOOL active;
@property (nonatomic, readonly) NSString *agreementDate; //"2016-11-23 13:51:41"
@property (nonatomic, readonly) NSString *ssn;
@property (nonatomic, readonly) NSString *licenseNumber;
@property (nonatomic, readonly) NSURL *licensePictureUrl;
@property (nonatomic, readonly) NSString *licenseExpiryDate; //"2017-05-02"
@property (nonatomic, readonly) NSString *licenseState;
@property (nonatomic, readonly) NSArray<Car*> *cars;
@property (nonatomic, readonly) NSNumber *rating;
@property (nonatomic, readonly) NSString *payoneerId;
@property (nonatomic, readonly) NSString *payoneerStatus;
@property (nonatomic, readonly) NSURL *payoneerSignupUrl;
@property (nonatomic, readonly) NSString *checkrStatus;
@property (nonatomic, readwrite) NSURL *photoUrl;
@property (nonatomic, readonly) NSString *activationDate; //"2017-04-14"
@property (nonatomic, readwrite) BOOL agreedToLegalTerms;
@property (nonatomic, readonly) BOOL fingerprintCleared;
@property (nonatomic, readonly) NSString *cityApprovalStatus;
@property (nonatomic, readonly) NSString *activationStatus;
@property (nonatomic, readonly) NSString *activationNotes;
@property (nonatomic, readonly) NSString *onboardingStatus;
@property (nonatomic, readonly) NSNumber *onboardingPendingSince; //1489508495000
@property (nonatomic, readonly) NSArray<NSString *> *grantedDriverTypes;
@property (nonatomic, readonly) NSNumber *cityId;
@property (nonatomic, readonly) NSArray *enabledRequestTypes; //not supported
@property (nonatomic, readonly) NSString *type;
@property (nonatomic, readonly) NSString *email;
@property (nonatomic, readonly) NSString *gender;
@property (nonatomic, readonly) NSString *firstname;
@property (nonatomic, readonly) NSString *lastname;
@property (nonatomic, readonly) NSString *phoneNumber;
@property (nonatomic, readonly) NSString *fullName;
@property (nonatomic, readonly) NSArray *checkrReports; //not supported
@property (nonatomic, readonly) BOOL chauffeurPermit;

- (Car *)selectedCar;

@end

@interface RADriverDataModel (UnitTests)

- (void)updateChauffeurPermit:(BOOL)hasChauffeurPermit;

@end

