//
//  LicenseDocumentViewController.m
//  RideDriver
//
//  Created by Roberto Abreu on 11/11/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "LicenseDocumentViewController.h"

#import "DocumentManager.h"
#import "RideDriver-Swift.h"
#import "UIImage+Ride.h"
#import "NSString+Utils.h"
#import "RAAlertManager.h"

#import "KLCPopup.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <UIActivityIndicator_for_SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>

@interface LicenseDocumentViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imgLicense;
@property (weak, nonatomic) IBOutlet UILabel *lbExpirationDate;
@property (weak, nonatomic) IBOutlet UITextField *txtExpirationDate;
@property (weak, nonatomic) IBOutlet UITextView *tvDescription;
@property (strong, nonatomic) RAPhotoPickerControllerManager *pickerManager;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (nonatomic) KLCPopup *datePopup;
@property (nonatomic) NSDate *dateSelected;
@property (nonatomic, assign) BOOL photoWasChanged;
@property (nonatomic, assign) BOOL dateWasChanged;
@property (nonatomic) RADocument *license;

@end

@implementation LicenseDocumentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setupData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self hideHUD];
}

- (void)setupUI {
    NSString *docsEmail = @"documents@rideaustin.com";
    self.title = [@"Driver's License" localized];
    self.tvDescription.text = [NSString stringWithFormat:@"To update your license, please send an email to %@".localized, docsEmail];
    //Setup Right BarButtonItem
    //UIBarButtonItem *updateBtn = [[UIBarButtonItem alloc] initWithTitle:[@"UPDATE" localized] style:UIBarButtonItemStylePlain target:self action:@selector(update)];
    
//    NSDictionary *attributes = @{
//      NSForegroundColorAttributeName : [UIColor navButtonEnabledBlueColor],
//      NSFontAttributeName : [UIFont fontWithName:@"Montserrat-Regular" size:15.0]
//    };
    
//    NSDictionary *attributesDisable = @{
//      NSForegroundColorAttributeName : [UIColor navButtonDisabledColor],
//      NSFontAttributeName : [UIFont fontWithName:@"Montserrat-Regular" size:15.0]
//    };
    
    //[updateBtn setTitleTextAttributes:attributes forState:UIControlStateNormal];
    //[updateBtn setTitleTextAttributes:attributesDisable forState:UIControlStateDisabled];
    //[updateBtn setEnabled:NO];
    //[self.navigationItem setRightBarButtonItem:updateBtn];
    
    //Setup Textfield Expiration Date
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 16, self.txtExpirationDate.bounds.size.height)];
    self.txtExpirationDate.leftView = leftView;
    self.txtExpirationDate.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, self.txtExpirationDate.bounds.size.height)];
    UIImageView *iconCalendar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-calendar"]];
    [iconCalendar setBounds:CGRectMake(0, 0, 18, 20)];
    [rightView addSubview:iconCalendar];
    iconCalendar.center = rightView.center;
    self.txtExpirationDate.rightView = rightView;
    self.txtExpirationDate.rightViewMode = UITextFieldViewModeAlways;
    
    self.txtExpirationDate.layer.borderWidth = 1;
    self.txtExpirationDate.layer.borderColor = [UIColor grayColor].CGColor;
    self.txtExpirationDate.layer.cornerRadius = 3.0;
    self.txtExpirationDate.layer.masksToBounds = YES;
    
    //Setup Date Picker
    self.datePicker = [[UIDatePicker alloc] init];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    self.datePicker.minimumDate = [NSDate new];
    self.datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [self.datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    [self.datePicker setBackgroundColor:[UIColor whiteColor]];
}

- (void)setupData {
    RADriverDataModel *driver = [RASessionManager shared].currentSession.driver;
    if (driver) {
        [self showHUD];
        [DocumentManager getLicenseWithCompletion:^(RADocument *doc, NSError *error) {
            [self hideHUD];
            if (error) {
                __weak __typeof__(self) weakself = self;
                RAAlertOption *option = [RAAlertOption optionWithState:StateActive];
                [option addAction:[RAAlertAction actionWithTitle:[@"Ok" localized] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    [weakself.navigationController popViewControllerAnimated:YES];
                }]];
                
                [RAAlertManager showErrorWithAlertItem:error andOptions:option];
            } else {
                self.license = doc;
            }
        }];
    }
}

- (void)setLicense:(RADocument *)license {
    _license = license;
    [self.imgLicense setImageWithURL:license.documentURL placeholderImage:[UIImage imageNamed:@"icon-license"] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    if ([license.validityDate isKindOfClass:[NSDate class]]) {
        self.txtExpirationDate.enabled = NO; //RA-14882
        self.txtExpirationDate.text = [[DocumentManager displayDateFormatter] stringFromDate:license.validityDate];
        self.dateSelected    = license.validityDate;
        self.datePicker.date = license.validityDate;
    } else {
        self.txtExpirationDate.text = @"";
        self.dateSelected = nil;
        
        //RA-14882
        self.txtExpirationDate.hidden = YES;
        self.lbExpirationDate.hidden = YES;
    }
}

- (IBAction)takePhotoPressed:(id)sender {
    [self.view endEditing:YES];
    __weak typeof(self) weakSelf = self;
    self.pickerManager = [RAPhotoPickerControllerManager pickerManager];
    [self.pickerManager showPickerControllerFromViewController:self sender:sender allowEditing:YES finishedBlock:^(UIImage *image, NSError *error) {
        if (error) {
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive]];
        } else {
            CGFloat maxArea = 480000;
            image = [UIImage imageWithImage:image scaledToMaxArea:maxArea];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.imgLicense.image = image;
                [weakSelf enableBtnUpdate:YES];
                weakSelf.photoWasChanged = YES;
            });
        }
    }
    accessDeniedBlock:^(NSString *errorTitle, NSString *errorMessage) {
        [RAAlertManager showAlertWithTitle:errorTitle message:errorMessage];
    }];
}

- (void)dateChanged:(UIDatePicker*)sender {
    self.txtExpirationDate.text = [[DocumentManager displayDateFormatter] stringFromDate:sender.date];
    self.dateSelected = sender.date;
    self.dateWasChanged = YES;
    [self enableBtnUpdate:YES];
}

- (void)update {
    [self enableBtnUpdate:NO];
    if (!self.dateSelected) {
        [RAAlertManager showErrorWithAlertItem:[@"Please, select a valid date" localized] andOptions:[RAAlertOption optionWithState:StateActive]];
        return;
    }
    NSNumber *cityId = [RASessionManager shared].currentSession.driver.cityId;
    
    
    BOOL hasDateChangedWithExistingPhoto  = self.dateWasChanged  && self.license;
    dispatch_group_t groupUpload = dispatch_group_create();
    __block NSError *errorUpload;
    [self showHUD];
    if (self.photoWasChanged) {
        dispatch_group_enter(groupUpload);
        [DocumentManager uploadLicensePhoto:self.imgLicense.image withExpirationDate:self.dateSelected atCityId:cityId completion:^(NSError *error) {
            errorUpload = error;
            dispatch_group_leave(groupUpload);
        }];
    } else if (hasDateChangedWithExistingPhoto) {
        dispatch_group_enter(groupUpload);
        self.license.validityDate = self.dateSelected;
        [DocumentManager updateDocument:self.license withCompletion:^(NSError *error) {
            errorUpload = error;
            dispatch_group_leave(groupUpload);
        }];
    }
    
    dispatch_group_notify(groupUpload, dispatch_get_main_queue(), ^{
        if (errorUpload) {
            [self hideHUD];
            [RAAlertManager showErrorWithAlertItem:errorUpload andOptions:[RAAlertOption optionWithState:StateActive]];
            [self enableBtnUpdate:YES];
            return;
        } else {
            [self showSuccessHUDandPOP];
        }
    });
}

- (void)enableBtnUpdate:(BOOL)isEnabled {
    UIBarButtonItem *updateBtn = [self.navigationItem rightBarButtonItem];
    if (updateBtn) {
        [updateBtn setEnabled:isEnabled];
    }
}

#pragma mark - UITextfield Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.txtExpirationDate) {
        [self.view endEditing:YES];
        self.datePopup = [KLCPopup popupWithContentView:self.datePicker showType:KLCPopupShowTypeBounceIn dismissType:KLCPopupDismissTypeBounceOut maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
        [self.datePopup show];
    }
}

@end
