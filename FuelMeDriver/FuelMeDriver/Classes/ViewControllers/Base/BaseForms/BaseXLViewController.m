//
//  BaseXLViewController.m
//  Ride
//
//  Created by Theodore Gonzalez on 5/18/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "BaseXLViewController.h"

#import "BaseXLTableViewCell.h"
#import "RAAlertManager.h"

@interface BaseXLViewController ()

@end

@implementation BaseXLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureTableView];
}
- (void)configureTableView {
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

@end

@implementation BaseXLViewController (validation)
-(BOOL)isFormValid {
    __weak __typeof__(self) weakself = self;
    __block NSString* message = @"";
    [self.view endEditing:YES];
    NSArray<NSError *> * array = [self formValidationErrors];
    [array enumerateObjectsUsingBlock:^(NSError *obj, NSUInteger idx, BOOL *stop)
     {
         XLFormValidationStatus * validationStatus = [[obj userInfo] objectForKey:@"XLValidationStatusErrorKey"];
         BaseXLTableViewCell * cell = (BaseXLTableViewCell *)[weakself.tableView cellForRowAtIndexPath:[weakself.form indexPathOfFormRow:validationStatus.rowDescriptor]];
         if ([message isEqualToString:@""]) {
             message = [[obj userInfo] objectForKey:@"NSLocalizedDescription"];
             [weakself.tableView scrollToRowAtIndexPath:[weakself.form indexPathOfFormRow:validationStatus.rowDescriptor] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
             [cell animate];
             *stop = YES;
         }
     }];
    
    if ([array count] > 0) {
        [RAAlertManager showErrorWithAlertItem:message andOptions:[RAAlertOption optionWithState:StateActive]];
    }
    
    return ([array count] ==0);
}
@end
