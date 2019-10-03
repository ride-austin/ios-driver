//
//  LostItemFormViewController.m
//  Ride
//
//  Created by Theodore Gonzalez on 5/18/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "LostItemFormViewController.h"

#import "LostItemViewModel.h"
#import "NSString+Utils.h"
#import "RAAlertManager.h"

@interface LostItemFormViewController ()

@property (nonatomic) LostItemViewModel *viewModel;

@end

@implementation LostItemFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.viewModel.headerText;
    [self configureFormBasedOnViewModel:self.viewModel];
}

- (void)setFormDataModel:(LIOptionDataModel *)formDataModel andRideId:(NSNumber *)rideId {
    _viewModel = [[LostItemViewModel alloc] initWithDataModel:formDataModel rideId:rideId];
}

- (void)configureFormBasedOnViewModel:(LostItemViewModel *)vm {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptor];
    XLFormSectionDescriptor * section = [XLFormSectionDescriptor formSection];
    XLFormRowDescriptor *row;
    [formDescriptor addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:vm.title
                                                rowType:vm.rowType];
    row.title = vm.title;
    row.value = vm.body;
    [section addFormRow:row];
    
    for (LIFieldViewModel *fieldvm in vm.fields) {
        if ([fieldvm.rowType isEqualToString:XLFormRowDescriptorTypeBaseXLDatePickerCell]) {
            row = [XLFormRowDescriptor  rowDatePickerWithTag:fieldvm.variable
                                                       title:fieldvm.title
                                                              value:nil
                                                        placeholder:fieldvm.placeholder
                                                            rowType:fieldvm.rowType
                                                              model:fieldvm.model
                                                     requireMessage:fieldvm.requireMsg];
            [section addFormRow:row];
        } else if ([fieldvm.rowType isEqualToString:XLFormRowDescriptorTypeBaseXLBooleanPickerCell]) {
            row = [XLFormRowDescriptor rowBooleanPickerWithTag:fieldvm.variable
                                                         title:fieldvm.title
                                                         value:nil
                                                   placeholder:fieldvm.placeholder
                                                       rowType:fieldvm.rowType
                                                requireMessage:fieldvm.requireMsg];
            
            [section addFormRow:row];
        } else if ([fieldvm.rowType isEqualToString:XLFormRowDescriptorTypeBaseXLImagePickerCell]) {
            row = [XLFormRowDescriptor rowImagePickerWithTag:fieldvm.variable
                                                       title:fieldvm.title
                                                     rowType:fieldvm.rowType
                                              requireMessage:fieldvm.requireMsg];
                   
            [section addFormRow:row];
        } else {
            row = [XLFormRowDescriptor rowTextFieldWithTag:fieldvm.variable
                                                     title:fieldvm.title
                                                             value:nil
                                                       placeholder:fieldvm.placeholder
                                                           rowType:fieldvm.rowType
                                                             model:fieldvm.model
                                                    requireMessage:fieldvm.requireMsg
                                                 andValidatorArray:nil];
            [section addFormRow:row];
        }
    }
    if (vm.actionButtonType != ActionButtonNone) {
        row = [XLFormRowDescriptor rowButtonWithTitleAndTag:vm.actionTitle
                                                    rowType:vm.actionRowType
                                                   selector:@selector(didTapSubmit)];
        [section addFormRow:row];
    }
    
    self.form = formDescriptor;
    [self.tableView reloadData];
}

- (void)didTapSubmit {
    if ([super isFormValid]) {
        __weak __typeof__(self) weakself = self;
        [self showHUD];
        [self.viewModel submitRequestWithFormValues:self.formValues withCompletion:^(NSString *successMessage, NSError *error) {
            [weakself hideHUD];
            if (error) {
                [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithShownOption:AllowNetworkError]];
            } else {
                RAAlertOption *option = [RAAlertOption optionWithState:StateActive];
                [option addAction:[RAAlertAction actionWithTitle:[@"Dismiss" localized] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    [weakself.navigationController popViewControllerAnimated:YES];
                }]];
                [RAAlertManager showAlertWithTitle:@"" message:successMessage options:option];
            }
        }];
    }
}

@end
