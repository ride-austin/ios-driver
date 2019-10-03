//
//  CFFormViewController.m
//  Ride
//
//  Created by Theodore Gonzalez on 3/24/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import "CFFormViewController.h"
#import "CFReasonTableViewCell.h"
#import "CFCommentCell.h"
#import "CFViewModel.h"
#import "RARideDataModel.h"
#import "RideDriver-Swift.h"
#import "RAAlertManager.h"

@interface CFFormViewController ()
@property (nonatomic, weak) IBOutlet UIView *tableHeaderView;
@property (nonatomic, weak) IBOutlet UIView *tableFooterView;
@property (nonatomic, weak) IBOutlet UILabel *lbTitle;
@property (nonatomic, weak) IBOutlet UILabel *lbSubtitle;

@property (nonatomic, weak) IBOutlet UIButton *btSubmit;
@property (nonatomic, weak) IBOutlet UIButton *btBack;
@property (nonatomic, strong) CFViewModel *viewModel;

@end

@implementation CFFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureDefaults];
    [self updateTextBasedOnViewModel:self.viewModel];
    __weak __typeof__(self) weakself = self;
    [self showHUD];
    [self.viewModel getReasonsWithCompletion:^(NSError *error) {
        [weakself hideHUD];
        [weakself configureFormBasedOnViewModel:weakself.viewModel];
        [weakself updateTableLayout];
    }];
}

- (void)configureDefaults {
    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    self.tableHeaderView.backgroundColor = self.transparentBlack;
    self.tableFooterView.backgroundColor = self.transparentBlack;
    self.btSubmit.enabled = NO;
    self.btBack.layer.borderWidth = 1.0;
    self.btBack.layer.borderColor = [UIColor azureBlue].CGColor;
}
 
- (CFViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [CFViewModel new];
    }
    return _viewModel;
}

- (void)setRide:(RARideDataModel *)ride {
    self.viewModel.ride = ride;
    [self updateTextBasedOnViewModel:self.viewModel];
}

- (void)updateTextBasedOnViewModel:(CFViewModel *)vm {
    self.lbTitle.text = vm.title;
    self.lbSubtitle.text = vm.subtitle;
}

- (void)configureFormBasedOnViewModel:(CFViewModel *)vm {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptor];
    XLFormSectionDescriptor * section = [XLFormSectionDescriptor formSection];
    XLFormRowDescriptor *row;
    [formDescriptor addFormSection:section];
    
    __weak __typeof__(self) weakself = self;
    void(^clearSelectionBlock)(NSString *) = ^(NSString *rowTag) {
        for (NSString *tag in [weakself reasonTags]) {
            if (![rowTag isEqualToString:tag]) {
                XLFormRowDescriptor *row = [weakself.form formRowWithTag:tag];
                row.value = @(NO);
                [weakself updateFormRow:row];
            }
        }
    };
    for (CFReasonDataModel *model in vm.items) {
        row = [XLFormRowDescriptor formRowDescriptorWithTag:model.code rowType:XLFormRowDescriptorTypeCFReasonTableViewCell title:model.reasonDescription];
        row.value = @(NO);
        [row.cellConfigAtConfigure setObject:clearSelectionBlock forKey:@"willSelectBlock"];
        [row.cellConfigAtConfigure setObject:self.transparentBlack forKey:@"backgroundColor"];
        [section addFormRow:row];
    }
    
    //
    XLFormRowDescriptor *otherRow = [formDescriptor formRowWithTag:@"OTHER"];
    if (otherRow) {
        row = [XLFormRowDescriptor rowTextFieldWithTag:@"COMMENT"
                                                 title:nil
                                                 value:nil
                                           placeholder:@"Enter your reason\n\n"
                                               rowType:XLFormRowDescriptorTypeCFCommentCell
                                                 model:[TextFieldModel details]
                                        requireMessage:nil
                                     andValidatorArray:nil];
        row.hidden = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"$%@.value == 0", otherRow]];
        [row.cellConfigAtConfigure setObject:self.transparentBlack forKey:@"backgroundColor"];
        [section addFormRow:row];
    }
    
    self.form = formDescriptor;
    [self.tableView reloadData];
}

- (void)updateTableLayout {
    CGFloat topInset = ([UIScreen mainScreen].bounds.size.height - self.tableView.contentSize.height);
    if (topInset > 0) {
        self.tableView.contentInset = UIEdgeInsetsMake(topInset, 0, 0, 0);
    }
}

- (void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)formRow oldValue:(id)oldValue newValue:(id)newValue {
    [super formRowDescriptorValueHasChanged:formRow oldValue:oldValue newValue:newValue];
    if (self.viewModel.items) {
        BOOL isEnabled = NO;
        for (NSString *tag in [self reasonTags]) {
            if ([@(YES) isEqualToNumber:self.formValues[tag]]) {
                isEnabled = YES;
            }
        }
        [self.btSubmit setEnabled:isEnabled];
    }
}

#pragma mark - Helpers

/**
 This is needed to make the whole transparent cell tappable
 */
- (UIColor *)transparentBlack {
    return [UIColor colorWithRed:0 green:0 blue:0 alpha:0.01];
}

- (NSArray<NSString *> *)reasonTags {
    return [self.viewModel.items valueForKey:@"code"];
}

#pragma mark - Actions

- (IBAction)didTapSubmit:(UIButton *)sender {
    __weak __typeof__(self) weakself = self;
    
    NSString *reason = [self.formValues allKeysForObject:@(YES)].firstObject;
    NSString *comment = [self.formValues[@"OTHER"] isKindOfClass:NSString.class] ? self.formValues[@"OTHER"] : nil;
    [self showHUD];
    [self.viewModel submitCancellationReason:reason comment:comment withCompletion:^(NSError * _Nullable error) {
        [weakself hideHUD];
        if (error) {
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithShownOption:AllowNetworkError]];
            if (error.code == 400 || error.code == 403) {
                //[weakself.eventPolling start];
            }
        } else {
            [weakself dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

- (IBAction)didTapBack:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

