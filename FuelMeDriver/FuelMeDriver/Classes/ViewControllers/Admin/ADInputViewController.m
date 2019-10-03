//
//  ADInputViewController.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 8/11/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "ADInputViewController.h"

#import "ADMenuViewController.h"
#import "BaseXLButtonCell.h"
#import "BaseXLTextViewCell.h"
#import "NetworkManager.h"
#import "UIStoryboard+UniqueViewControllerFactory.h"

@interface ADInputViewController ()

@end

@implementation ADInputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureForm];
}

- (void)configureForm {
    XLFormDescriptor *formDescriptor = [XLFormDescriptor formDescriptor];
    XLFormSectionDescriptor *section = [XLFormSectionDescriptor formSection];
    XLFormRowDescriptor *row;
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor rowTextFieldWithTag:@"driverID"
                                             title:@"DriverID"
                                             value:nil
                                       placeholder:@"Enter Driver ID in Austin"
                                           rowType:XLFormRowDescriptorTypeBaseXLTextViewCell
                                             model:[TextFieldModel phone]
                                    requireMessage:@"DriverID is required"
                                 andValidatorArray:nil];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor rowButtonWithTitleAndTag:@"SUBMIT"
                                                rowType:XLFormRowDescriptorTypeBaseXLButtonCell
                                               selector:@selector(didTapSubmit)];
    [section addFormRow:row];
    self.form = formDescriptor;
    [self.tableView reloadData];
}

- (void)didTapSubmit {
    if ([super isFormValid]) {
        NSString *driverID = self.formValues[@"driverID"];
        [self showMenuWithDriver:driverID];
    }
}

- (void)showMenuWithDriver:(NSString *)driverID {
    ADMenuViewController *vc = (ADMenuViewController *)[UIStoryboard viewControllerForID:ADMenuViewController.className];
    vc.driverID = driverID;
    [self.navigationController pushViewController:vc animated:YES];

}

@end
