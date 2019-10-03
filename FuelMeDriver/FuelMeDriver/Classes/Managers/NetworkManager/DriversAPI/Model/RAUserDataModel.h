//
//  RAUserDataModel.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 8/30/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RAAvatarDataModel.h"
#import "RABaseDataModel.h"
#import "RARideAddressDataModel.h"

@interface RAUserDataModel : RABaseDataModel
@property (nonatomic, readonly, copy) NSURL *photoUrl;
@property (nonatomic, readonly, copy) NSString *email;
@property (nonatomic, readonly, copy) NSString *firstname;
@property (nonatomic, readonly, copy) NSString *lastname;
@property (nonatomic, readonly, copy) NSString *nickName;
@property (nonatomic, readonly, copy) NSString *phoneNumber;
@property (nonatomic, readonly, copy) RARideAddressDataModel *address;
@property (nonatomic, readonly, copy) NSString *dateOfBirth;
@property (nonatomic, readonly, copy) NSString *gender;
//@property (nonatomic, readonly, copy) NSString *fullName; //removed from server
//@property (nonatomic, readonly, copy) NSString *uuid; //duplicates modelID
@property (nonatomic, readonly) BOOL phoneNumberVerified;
@property (nonatomic, readonly) BOOL enabled;
@property (nonatomic, readonly) BOOL active;
@property (nonatomic, readonly, copy) NSArray<RAAvatarDataModel *> *avatars;
- (NSString *)fullName;
- (BOOL)hasDriverAvatar;
- (BOOL)hasAdminAvatar;

@end

@interface RAUserDataModel (UpdateUserConstructor)

- (void)updateEmail:(NSString *)email
          firstname:(NSString *)firstname
           lastname:(NSString *)lastname
           nickName:(NSString *)nickName
        phoneNumber:(NSString *)phoneNumber;

@end
