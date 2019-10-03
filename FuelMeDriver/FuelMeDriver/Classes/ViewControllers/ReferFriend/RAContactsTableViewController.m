//
//  RAContactsTableViewController.m
//  RideDriver
//
//  Created by Kitos on 5/11/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "RAContactsTableViewController.h"

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "RAAlertManager.h"

#import "NSString+Utils.h"
#import "RAContacts.h"

#import <SVProgressHUD/SVProgressHUD.h>

@interface RAContactItem : NSObject 

@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subtitle;
@property (nonatomic) RAContactItemType type;

@end

@implementation RAContactItem

@end

@interface RAContactsTableViewController ()

@property (nonatomic, strong) NSArray <RAContact*> *datasource;

@property (nonatomic, strong) UIImage *phoneIcon;
@property (nonatomic, strong) UIImage *emailIcon;

@property (nonatomic, strong) ABPeoplePickerNavigationController *addressBookController; //iOS 8
@property (nonatomic, strong) NSMutableArray <RAContact*> *datasourceM; //iOS 8

@end

@interface RAContactsTableViewController (AddressBookPickerDelegate) <ABPeoplePickerNavigationControllerDelegate>

@end

@interface RAContactsTableViewController (Private)

- (void)fetchData;
- (void)fetchPhonesWithCompletion:(RAContactsGetAllBlock)handler;
- (void)fetchEmailsWithCompletion:(RAContactsGetAllBlock)handler;
- (void)fetchAllWithCompletion:(RAContactsGetAllBlock)handler;

- (RAContact*)contactAtSection:(NSInteger)section;
- (RAContactItem*)itemForIndexPath:(NSIndexPath*)ip;

//iOS 8
- (void)showAddressBook;

@end

@implementation RAContactsTableViewController

- (void)setFilter:(RAContactItemType)filter {
    _filter = filter;
}

- (void)setDatasource:(NSArray<RAContact *> *)datasource {
    _datasource = datasource;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.phoneIcon = [UIImage imageNamed:@"iconPhone"];
        self.emailIcon = [UIImage imageNamed:@"iconEnvelopeGray"];
        
        self.filter = RATypeAll;
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [@"Contacts" localized];
    if (!IS_GREATER_THAN_OR_EQUAL_VERSION(9.0)) {
        [self showAddressBook];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (IS_GREATER_THAN_OR_EQUAL_VERSION(9.0)) {
        [self fetchData];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (IS_GREATER_THAN_OR_EQUAL_VERSION(9.0)) {
        return self.datasource.count;
    }
    else {
        return self.datasourceM.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    RAContact *contact = [self contactAtSection: section];
    NSInteger rows = 0;
    switch (self.filter) {
        case RATypeAll:
            rows += (contact.phones.count + contact.emails.count);
            break;
        case RATypePhone:
            rows += (contact.phones.count);
            break;
        case RATypeEmail:
            rows += (contact.emails.count);
            break;
            
        default:
            break;
    }
    return rows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    RAContact *contact = [self contactAtSection: section];
    return [NSString stringWithFormat:@"%@ %@",contact.lastname,contact.firstname];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contactCell" forIndexPath:indexPath];
    
    RAContactItem *item = [self itemForIndexPath:indexPath];
    
    [cell.imageView setImage:item.icon];
    [cell.textLabel setText:item.title];
    [cell.detailTextLabel setText:item.subtitle];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(contactItemHasBeenselected:itemType:)]) {
        RAContactItem *item = [self itemForIndexPath:indexPath];

        [self.delegate contactItemHasBeenselected:item.subtitle itemType:item.type];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end

#pragma mark - AddressBook Picker Delegate

@implementation RAContactsTableViewController (AddressBookPickerDelegate)

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person {
    RAContact *contact = [RAContact new];
    
    // Use a general Core Foundation object.
    CFTypeRef generalCFObject = ABRecordCopyValue(person, kABPersonFirstNameProperty);
    
    // Get the first name.
    if (generalCFObject) {
        contact.firstname = (__bridge NSString *)generalCFObject;
        CFRelease(generalCFObject);
    }
    
    // Get the last name.
    generalCFObject = ABRecordCopyValue(person, kABPersonLastNameProperty);
    if (generalCFObject) {
        contact.lastname = (__bridge NSString *)generalCFObject;
        CFRelease(generalCFObject);
    }
    
    if (self.filter == RATypeAll || self.filter == RATypePhone) {
        // Get the phone numbers as a multi-value property.
        NSMutableArray *phones = [NSMutableArray array];
        ABMultiValueRef phonesRef = ABRecordCopyValue(person, kABPersonPhoneProperty);
        for (int i=0; i<ABMultiValueGetCount(phonesRef); i++) {
            CFStringRef currentPhoneLabel = ABMultiValueCopyLabelAtIndex(phonesRef, i);
            CFStringRef currentPhoneValue = ABMultiValueCopyValueAtIndex(phonesRef, i);
            
            RALabeledValue *labeledPhone = [RALabeledValue new];
            labeledPhone.label = (__bridge NSString *)currentPhoneLabel;
            labeledPhone.value = (__bridge NSString *)currentPhoneValue;
            
            CFRelease(currentPhoneLabel);
            CFRelease(currentPhoneValue);
            
            [phones addObject:labeledPhone];
        }
        CFRelease(phonesRef);
        
        if (phones.count > 0) {
            contact.phones = [NSArray arrayWithArray:phones];
        }
    }
    
    if (self.filter == RATypeAll || self.filter == RATypeEmail) {
        // Get the e-mail addresses as a multi-value property.
        NSMutableArray *emails = [NSMutableArray array];
        ABMultiValueRef emailsRef = ABRecordCopyValue(person, kABPersonEmailProperty);
        for (int i=0; i<ABMultiValueGetCount(emailsRef); i++) {
            CFStringRef currentEmailLabel = ABMultiValueCopyLabelAtIndex(emailsRef, i);
            CFStringRef currentEmailValue = ABMultiValueCopyValueAtIndex(emailsRef, i);
            
            RALabeledValue *labeledEmail = [RALabeledValue new];
            labeledEmail.label = (__bridge NSString *)currentEmailLabel;
            labeledEmail.value = (__bridge NSString *)currentEmailValue;
            
            CFRelease(currentEmailLabel);
            CFRelease(currentEmailValue);
            [emails addObject:labeledEmail];
        }
        CFRelease(emailsRef);
        
        if (emails.count > 0) {
            contact.emails = [NSArray arrayWithArray:emails];
        }
    }
    
    // Initialize the array if it's not yet initialized.
    if (self.datasourceM == nil) {
        self.datasourceM = [[NSMutableArray alloc] init];
    }
    // Add the dictionary to the array.
    [self.datasourceM addObject:contact];
    
    // Reload the table view data.
    [self.tableView reloadData];
    
    // Dismiss the address book view controller.
    [_addressBookController dismissViewControllerAnimated:YES completion:nil];
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [_addressBookController dismissViewControllerAnimated:YES completion:nil];
}

@end

#pragma mark - Private

@implementation RAContactsTableViewController (Private)

- (void)fetchData {
    
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD showWithStatus:NSLocalizedString(@"PLEASE WAIT...", "")];
    
    switch (self.filter) {
        case RATypeAll:{
            
            __weak RAContactsTableViewController *weakSelf = self;
            [self fetchAllWithCompletion:^(NSArray<RAContact *> *contacts, NSError *error) {
                
                weakSelf.datasource = contacts;
                
                [SVProgressHUD dismiss];
                
                if (error) {
                    NSString *message = ((error.localizedRecoverySuggestion) == nil) ? error.localizedDescription : error.localizedRecoverySuggestion;
                    
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:kDefaultErrorAlertTitle message: message preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *dismiss = [UIAlertAction actionWithTitle:[@"Ok" localizedUppercaseString] style:UIAlertActionStyleCancel handler:nil];
                    [alertController addAction:dismiss];
                    
                    [weakSelf presentViewController:alertController animated:YES completion:nil];
                }

            }];
            
        }
            
            break;

        case RATypePhone:{
            
            __weak RAContactsTableViewController *weakSelf = self;
            [self fetchPhonesWithCompletion:^(NSArray<RAContact *> *contacts, NSError *error) {
                weakSelf.datasource = contacts;
                
                [SVProgressHUD dismiss];
                
                if (error) {
                    NSString *message = ((error.localizedRecoverySuggestion) == nil) ? error.localizedDescription : error.localizedRecoverySuggestion;
                    
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:kDefaultErrorAlertTitle message: message preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *dismiss = [UIAlertAction actionWithTitle:[@"Ok" localizedUppercaseString] style:UIAlertActionStyleCancel handler:nil];
                    [alertController addAction:dismiss];
                    
                    [weakSelf presentViewController:alertController animated:YES completion:nil];
                }
                
            }];
        }
            
            break;

        case RATypeEmail:{

            __weak RAContactsTableViewController *weakSelf = self;
            [self fetchEmailsWithCompletion:^(NSArray<RAContact *> *contacts, NSError *error) {
              
                weakSelf.datasource = contacts;
                
                [SVProgressHUD dismiss];

                if (error) {
                    NSString *message = ((error.localizedRecoverySuggestion) == nil) ? error.localizedDescription : error.localizedRecoverySuggestion;
                    
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:kDefaultErrorAlertTitle message: message preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *dismiss = [UIAlertAction actionWithTitle:[@"Ok" localizedUppercaseString] style:UIAlertActionStyleCancel handler:nil];
                    [alertController addAction:dismiss];
                    
                    [weakSelf presentViewController:alertController animated:YES completion:nil];
                }
                
            }];
        }
            break;

        default:
            break;
    }
    
}

- (void)fetchPhonesWithCompletion:(RAContactsGetAllBlock)handler {
    [RAContacts getAllPhoneContactsWithCompletion:handler];
}

- (void)fetchEmailsWithCompletion:(RAContactsGetAllBlock)handler {
    [RAContacts getAllEmailContactsWithCompletion:handler];
}

- (void)fetchAllWithCompletion:(RAContactsGetAllBlock)handler {
    [RAContacts getAllContactsWithPhones:YES emails:YES completion:handler];
}

- (RAContact *)contactAtSection:(NSInteger)section {
    return IS_GREATER_THAN_OR_EQUAL_VERSION(9.0) ? self.datasource[section] : self.datasourceM[section];
}

- (RAContactItem *)itemForIndexPath:(NSIndexPath *)ip {
    RAContact *contact = [self contactAtSection: ip.section];
    
    UIImage *icon = nil;
    RALabeledValue *labeledValue = nil;
    RAContactItemType type = RATypeAll;
    
    switch (self.filter) {
        case RATypeAll:
            if (ip.row < contact.phones.count) {
                icon = self.phoneIcon;
                labeledValue = contact.phones[ip.row];
                type = RATypePhone;
            }
            else{
                icon = self.emailIcon;
                labeledValue = contact.emails[ip.row - contact.phones.count];
                type = RATypeEmail;
            }
            break;

        case RATypePhone:
            icon = self.phoneIcon;
            labeledValue = contact.phones[ip.row];
            type = RATypePhone;
            break;
  
        case RATypeEmail:
            icon = self.emailIcon;
            labeledValue = contact.emails[ip.row];
            type = RATypeEmail;
            break;
            
        default:
            break;
    }

    RAContactItem *item = [RAContactItem new];
    item.icon = icon;
    item.type = type;
    item.title = labeledValue.label;
    item.subtitle = labeledValue.value;
    
    return item;
}

//iOS 8
- (void)showAddressBook {
    _addressBookController = [[ABPeoplePickerNavigationController alloc] init];
    [_addressBookController setPeoplePickerDelegate:self];
    [self presentViewController:_addressBookController animated:YES completion:nil];
}

@end
