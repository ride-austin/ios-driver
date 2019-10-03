//
//  RAContacts.m
//  RideDriver
//
//  Created by Kitos on 5/11/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "RAContacts.h"

#import <Contacts/Contacts.h>

#import "ConfigurationManager.h"

@interface RAContacts (Private)

+ (void)retrieveAllContactsWithPhones:(BOOL)hasPhone emails:(BOOL)hasEmail completion:(RAContactsGetAllBlock)handler;
+ (RAContact*)parseContactWithContact:(CNContact *)contact;

@end

@implementation RAContacts

+ (void)getAllPhoneContactsWithCompletion:(RAContactsGetAllBlock)handler {
    [self getAllContactsWithPhones:YES emails:NO completion:handler];
}

+ (void)getAllEmailContactsWithCompletion:(RAContactsGetAllBlock)handler {
    [self getAllContactsWithPhones:NO emails:YES completion:handler];
}

+ (void)getAllContactsWithPhones:(BOOL)hasPhone emails:(BOOL)hasEmail completion:(RAContactsGetAllBlock)handler {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (IS_GREATER_THAN_OR_EQUAL_VERSION(9.0)) {
            CNEntityType entityType = CNEntityTypeContacts;
            if( [CNContactStore authorizationStatusForEntityType:entityType] == CNAuthorizationStatusNotDetermined) {
                CNContactStore * contactStore = [[CNContactStore alloc] init];
                [contactStore requestAccessForEntityType:entityType completionHandler:^(BOOL granted, NSError * _Nullable error) {
                    if(granted){
                        [self retrieveAllContactsWithPhones:hasPhone emails:hasEmail completion:^(NSArray<RAContact *> *contacts, NSError *error) {
                            if (handler) {
                                handler(contacts, error);
                            }
                        }];
                    }
                }];
            } else if( [CNContactStore authorizationStatusForEntityType:entityType]== CNAuthorizationStatusAuthorized) {
                [self retrieveAllContactsWithPhones:hasPhone emails:hasEmail completion:^(NSArray<RAContact *> *contacts, NSError *error) {
                    if (handler) {
                        handler(contacts, error);
                    }
                }];
            } else {
                NSString *message = [NSString stringWithFormat:@"You have not authorized %@ to access your contacts. Go to settings -> Privacy -> Contacts and authorize %@.", [ConfigurationManager localAppName], [ConfigurationManager localAppName]];
                NSError *error = [NSError errorWithDomain:@"com.rideaustin.error.contacts.unauthorized" code:-1 userInfo:@{NSLocalizedDescriptionKey: message}];
                if (handler) {
                    handler(nil, error);
                }
            }
        } else {
            NSLog(@"For iOS<9.0 use AddressBook");
        }
    });
}

@end

#pragma mark - Private

@implementation RAContacts (Private)

+ (void)retrieveAllContactsWithPhones:(BOOL)hasPhone emails:(BOOL)hasEmail completion:(RAContactsGetAllBlock)handler {
    NSError *contactError;
    CNContactStore *addressBook = [[CNContactStore alloc]init];
    [addressBook containersMatchingPredicate:[CNContainer predicateForContainersWithIdentifiers: @[addressBook.defaultContainerIdentifier]] error:&contactError];
    NSArray *keysToFetch = @[CNContactEmailAddressesKey, CNContactPhoneNumbersKey, CNContactFamilyNameKey, CNContactGivenNameKey];
    CNContactFetchRequest *request = [[CNContactFetchRequest alloc]initWithKeysToFetch:keysToFetch];
    
    NSMutableArray *contacts = [NSMutableArray array];
    BOOL success = [addressBook enumerateContactsWithFetchRequest:request error:&contactError usingBlock:^(CNContact * __nonnull contact, BOOL * __nonnull stop){
        RAContact *c = [self parseContactWithContact:contact];
        if ((c.phones.count > 0 || c.emails.count > 0) && ((c.phones.count > 0  && hasPhone) || !hasPhone) && ((c.emails.count > 0 && hasEmail) || !hasEmail)) {
            [contacts addObject:c];
        }
    }];
    
    if (handler) {
        NSError *err = contactError;
        if(!success && !err){
            err = [NSError errorWithDomain:@"com.rideaustin.error.getContacts" code:-2 userInfo:@{NSLocalizedDescriptionKey: @"Cannot retrieve contacts - Unknown error."}];
        }
        handler(contacts, err);
    }
}

+ (RAContact *)parseContactWithContact:(CNContact *)contact {
    NSString * firstName =  contact.givenName;
    NSString * lastName =  contact.familyName;
    NSArray * phones = nil;
    if (contact.phoneNumbers.count > 0) {
        NSMutableArray *phonesM = [NSMutableArray arrayWithCapacity:contact.phoneNumbers.count];
        for (CNLabeledValue<CNPhoneNumber*> *phoneNumber in contact.phoneNumbers) {
            RALabeledValue *labeledPhone = [RALabeledValue new];
            labeledPhone.label = phoneNumber.label;
            labeledPhone.value = [phoneNumber.value stringValue];
            
            [phonesM addObject:labeledPhone];
        }
        phones = [NSArray arrayWithArray:phonesM];
    }
    NSArray *emails = nil;
    if (contact.emailAddresses.count > 0) {
        NSMutableArray *emailsM = [NSMutableArray arrayWithCapacity:contact.emailAddresses.count];
        for (CNLabeledValue<NSString*> *emailAddress in contact.emailAddresses) {
            RALabeledValue *labeledEmail = [RALabeledValue new];
            labeledEmail.label = emailAddress.label;
            labeledEmail.value = emailAddress.value;
            
            [emailsM addObject:labeledEmail];
        }
        emails = [NSArray arrayWithArray:emailsM];
    }
    
    RAContact *aContact = [RAContact new];
    aContact.firstname = firstName;
    aContact.lastname = lastName;
    aContact.phones = phones;
    aContact.emails = emails;
    
    return aContact;
}

@end
