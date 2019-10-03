//
//  RAContacts.h
//  RideDriver
//
//  Created by Kitos on 5/11/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RAContact.h"

typedef void(^RAContactsGetAllBlock)(NSArray<RAContact*> *contacts, NSError *error);

@interface RAContacts : NSObject

+ (void)getAllPhoneContactsWithCompletion:(RAContactsGetAllBlock)handler;
+ (void)getAllEmailContactsWithCompletion:(RAContactsGetAllBlock)handler;
+ (void)getAllContactsWithPhones:(BOOL)hasPhone emails:(BOOL)hasEmail completion:(RAContactsGetAllBlock)handler;

@end
