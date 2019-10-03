//
//  RAUserDataModel.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 8/30/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RAUserDataModel.h"

#import "RARideAddressDataModel.h"

@implementation RAUserDataModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return
    @{
      @"modelID" : @"id",
      @"photoUrl" : @"photoUrl",
      @"email" : @"email",
      @"firstname" : @"firstname",
      @"lastname" : @"lastname",
      @"nickName" : @"nickName",
      @"phoneNumber" : @"phoneNumber",
      @"phoneNumberVerified" : @"phoneNumberVerified",
      @"address" : @"address",
      @"dateOfBirth" : @"dateOfBirth",
      @"gender" : @"gender",
//      @"fullName" : @"fullName",
    //@"uuid" : @"uuid",
      @"enabled" : @"enabled",
      @"active" : @"active",
      @"avatars" : @"avatars"
      };
}

+ (NSValueTransformer *)addressJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        return [MTLJSONAdapter modelOfClass:RARideAddressDataModel.class fromJSONDictionary:value error:error];
    } reverseBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        NSDictionary *object = [MTLJSONAdapter JSONDictionaryFromModel:value error:error];
        return object;
    }];
}

+ (NSValueTransformer *)avatarsJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        return [MTLJSONAdapter modelsOfClass:RAAvatarDataModel.class fromJSONArray:value error:error];
    } reverseBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        NSDictionary *object = [MTLJSONAdapter JSONDictionaryFromModel:value error:error];
        return object;
    }];
}

- (NSString *)fullName {
    if (self.firstname && self.lastname) {
        return [NSString stringWithFormat:@"%@ %@", self.firstname, self.lastname];
    }
    return nil;
}

- (BOOL)hasDriverAvatar {
    for (RAAvatarDataModel *avatar in self.avatars) {
        if ([@"DRIVER" isEqualToString:avatar.type]) {
            return YES;
        }
    }
    return NO;
}
- (BOOL)hasAdminAvatar {
    for (RAAvatarDataModel *avatar in self.avatars) {
        if ([@"ADMIN" isEqualToString:avatar.type]) {
            return YES;
        }
    }
    return NO;
}
- (void)updateEmail:(NSString *)email firstname:(NSString *)firstname lastname:(NSString *)lastname nickName:(NSString *)nickName phoneNumber:(NSString *)phoneNumber {
    _email       = email;
    _firstname   = firstname;
    _lastname    = lastname;
    _nickName    = nickName;
    _phoneNumber = phoneNumber;
}
@end
