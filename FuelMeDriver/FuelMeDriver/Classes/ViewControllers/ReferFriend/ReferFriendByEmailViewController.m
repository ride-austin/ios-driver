//
//  ReferFriendByEmailViewController.m
//  RideDriver
//
//  Created by Carlos Alcala on 9/14/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "ReferFriendByEmailViewController.h"

#import "NSString+Utils.h"
#import "RAContactsTableViewController.h"
#import "RADriversAPI.h"
#import "UITextField+Valid.h"
#import "RAAlertManager.h"

@interface ReferFriendByEmailViewController ()

@end

@interface ReferFriendByEmailViewController (Contactsdelegate) <RAContactsTableViewControllerDelegate>

@end

@implementation ReferFriendByEmailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = [@"Refer By Email" localized];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationItem.titleView = nil;
    [self.emailTextfield resignFirstResponder];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"kShowContactsFromEmailSegue"]) {
        RAContactsTableViewController *ctvc = (RAContactsTableViewController*)segue.destinationViewController;
        ctvc.delegate = self;
        ctvc.filter = RATypeEmail;
    }
}

#pragma mark - Actions

- (IBAction)emailAction:(UIButton *)sender {
    [self sendAction];
}

- (void)sendAction {
    if (![self validate]) {
        return;
    }
    
    [self.emailTextfield resignFirstResponder];
    
    //API call to send Refer by Email
    [self showHUD];
    
    __weak ReferFriendByEmailViewController *weakSelf = self;
    [RADriversAPI postReferAFriendByEmail:self.emailTextfield.text withCompletion:^(id response, NSError *error) {
        [weakSelf hideHUD];
        if (error) {
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive]];
        } else {
            [RAAlertManager showAlertWithTitle:[@"Refer A Friend" localized] message:[@"An Email message to refer your friend has been sent." localized] options:[RAAlertOption optionWithState:StateActive]];
        }
    }];
}

#pragma mark - Helper Functions

- (BOOL)validate {
    NSString *message = nil;
    
    if([self.emailTextfield isEmpty]) {
        message = [@"Please enter your email address." localized];
    } else {
        if (![self.emailTextfield isValidEmail]) {
            message =  [@"Please enter a valid email address." localized];
        }
    }
    
    if (message) {
        [RAAlertManager showErrorWithAlertItem:message andOptions:[RAAlertOption optionWithState:StateActive andShownOption:Overlap]];
        [self.emailTextfield becomeFirstResponder];
        return NO;
    }
    
    return YES;
}

#pragma mark - TextField Delegate Functions

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailTextfield) {
        [self sendAction];
    }
    return YES;
}

@end

#pragma mark - Contacts Delegate

@implementation ReferFriendByEmailViewController (Contactsdelegate)

- (void)contactItemHasBeenselected:(NSString *)item itemType:(RAContactItemType)type {
    NSLog(@"contact irem seleted email: %@",item);
    self.emailTextfield.text = item;
}

@end

