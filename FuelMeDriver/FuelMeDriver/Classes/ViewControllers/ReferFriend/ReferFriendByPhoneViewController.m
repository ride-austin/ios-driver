//
//  ReferFriendByPhoneViewController.m
//  RideDriver
//
//  Created by Carlos Alcala on 9/14/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "ReferFriendByPhoneViewController.h"

#import "NSString+Utils.h"
#import "RAContactsTableViewController.h"
#import "RADriversAPI.h"
#import "UITextField+Valid.h"
#import "RAAlertManager.h"

@interface ReferFriendByPhoneViewController ()

@end

@interface ReferFriendByPhoneViewController (Contactsdelegate) <RAContactsTableViewControllerDelegate>

@end

@implementation ReferFriendByPhoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = [@"Refer By Phone" localized];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationItem.titleView = nil;
    [self.phoneTextfield resignFirstResponder];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"kShowContactsFromPhoneSegue"]) {
        RAContactsTableViewController *ctvc = (RAContactsTableViewController*)segue.destinationViewController;
        ctvc.delegate = self;
        ctvc.filter = RATypePhone;
    }
}

#pragma mark - Actions

- (IBAction)phoneAction:(UIButton *)sender {
    [self sendAction];
}

- (void)sendAction {
    
    if (![self validate]) {
        return;
    }
    
    [self.phoneTextfield resignFirstResponder];
    

    //generate valid E164 phone number to send SMS
    NSString* phoneNumber = [self.phoneTextfield.text validPhoneWithSINFormat:SINPhoneNumberFormatE164];
    
    DBLog(@"PHONE NUMBER E164: %@", phoneNumber);
    
    //API call to send Refer by Email
    [self showHUD];
    
    __weak ReferFriendByPhoneViewController *weakSelf = self;
    [RADriversAPI postReferAFriendBySMS:phoneNumber withCompletion:^(id response, NSError *error) {
        [weakSelf hideHUD];
        if (error) {
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive]];
        } else {
            [RAAlertManager showAlertWithTitle:[@"Refer A Friend" localized] message:[@"An SMS message to refer your friend has been sent." localized] options:[RAAlertOption optionWithState:StateActive]];
        }
    }];
}

#pragma mark - Helper Functions

- (BOOL)validate {
    
    NSString* message = nil;
    
    if([self.phoneTextfield isEmpty]) {
        message = [@"Please enter a number." localized];
    } else {
        if (![self.phoneTextfield isValidPhone]) {
            message =  [@"Please enter a valid phone number." localized];
        }
    }
    
    if (message) {
        [RAAlertManager showErrorWithAlertItem:message andOptions:[RAAlertOption optionWithState:StateActive andShownOption:Overlap]];
        [self.phoneTextfield becomeFirstResponder];
        return NO;
    }
    
    return YES;
}

#pragma mark - TextField Delegate Functions

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.phoneTextfield) {
        [self sendAction];
    }
    return YES;
}

@end

#pragma mark - Contacts Delegate

@implementation ReferFriendByPhoneViewController (Contactsdelegate)

- (void)contactItemHasBeenselected:(NSString *)item itemType:(RAContactItemType)type {
    NSLog(@"contact irem seeted phone: %@",item);
    self.phoneTextfield.text = item;
}

@end
