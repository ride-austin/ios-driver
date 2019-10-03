//
//  InsuranceDocumentViewController.m
//  RideDriver
//
//  Created by Roberto Abreu on 11/11/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "InsuranceDocumentViewController.h"

#import "DocumentManager.h"
#import "UIColor+HexUtils.h"
#import "RideDriver-Swift.h"
#import "UIImage+Ride.h"
#import "NSString+Utils.h"
#import "RAAlertManager.h"

#import "KLCPopup.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <UIActivityIndicator_for_SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>

@interface InsuranceDocumentViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imgInsurance;
@property (weak, nonatomic) IBOutlet UILabel *lbExpirationDate;
@property (weak, nonatomic) IBOutlet UITextField *txtExpirationDate;
@property (weak, nonatomic) IBOutlet UITextView *tvInsuranceInformation;
@property (nonatomic) RAPhotoPickerControllerManager *pickerManager;
@property (strong,nonatomic) UIDatePicker *datePicker;
@property (nonatomic) KLCPopup *datePopup;
@property (nonatomic) NSDate *dateSelected;
@property (nonatomic, assign) BOOL photoWasChanged;
@property (nonatomic, assign) BOOL dateWasChanged;
@property (nonatomic) RADocument *document;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBottomSpaceBTTakePhoto; //-65 hidden or 16 visible

@end

@implementation InsuranceDocumentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUI];
    
    if (!self.isNewCar) {
        self.constraintBottomSpaceBTTakePhoto.constant = -65;
        [self configureData];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self hideHUD];
}

- (void)configureUI {
    
    self.title = @"Insurance";
    
    //Setup Right BarButtonItem
    NSString *btnTitle = self.isNewCar ? [@"SAVE" localizedCapitalizedString] : [@"UPDATE" localizedCapitalizedString];
    UIBarButtonItem *updateBtn = [[UIBarButtonItem alloc] initWithTitle:btnTitle style:UIBarButtonItemStylePlain target:self action:@selector(btSaveUpdateTapped)];
    
    NSDictionary *attributes = @{
                                 NSForegroundColorAttributeName : UIColor.barButtonEnabled,
                                 NSFontAttributeName : [UIFont fontWithName:@"Montserrat-Regular" size:15.0]
                                };
    
    NSDictionary *attributesDisable = @{
                                 NSForegroundColorAttributeName : UIColor.barButtonDisabled,
                                 NSFontAttributeName : [UIFont fontWithName:@"Montserrat-Regular" size:15.0]
                                 };
    
    [updateBtn setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [updateBtn setTitleTextAttributes:attributesDisable forState:UIControlStateDisabled];
    [updateBtn setEnabled:NO];
    if (self.isNewCar) {
        [self.navigationItem setRightBarButtonItem:updateBtn];
    } else {
        //RA-14882
    }
    
    
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
    [self.datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    [self.datePicker setBackgroundColor:[UIColor whiteColor]];
    
    if (self.isNewCar) {
        [updateBtn setEnabled:YES];
        self.navigationItem.hidesBackButton = YES;
        self.tvInsuranceInformation.font = [UIFont fontWithName:@"Montserrat-Light" size:18.0];
        self.tvInsuranceInformation.textColor = [UIColor colorWithHex:@"3C4350"];
        self.tvInsuranceInformation.textAlignment = NSTextAlignmentCenter;
        self.tvInsuranceInformation.text = @"Update your insurance photo";
    } else {
        NSString *email = @"documents@rideaustin.com";
        self.tvInsuranceInformation.text = [NSString stringWithFormat:@"To update your insurance photo, please send it to %@", email];
    }
    
    
}

- (void)configureData {
    if (self.selectedCar) {
        
        if (!self.selectedCar.inspectionNotes) {
            //Set default value to inspection notes
            self.selectedCar.inspectionNotes = @"";
        }
        
        if (self.selectedCar.insurancePictureUrl) {
            [self showHUD];
            [DocumentManager getInsuranceForCarId:self.selectedCar.modelID.stringValue completion:^(RADocument *insurance, NSError *error) {
                [self hideHUD];
                if (error) {
                    __weak __typeof__(self) weakself = self;
                    RAAlertOption *option = [RAAlertOption optionWithState:StateActive];
                    [option addAction:[RAAlertAction actionWithTitle:[@"Ok" localized] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        [weakself.navigationController popViewControllerAnimated:YES];
                    }]];
                    
                    [RAAlertManager showErrorWithAlertItem:error andOptions:option];
                } else {
                    self.document = insurance;
                }
            }];
        } else {
            //RA-14882
            self.txtExpirationDate.hidden = YES;
            self.lbExpirationDate.hidden = YES;
        }
    }
}

- (void)setDocument:(RADocument *)document {
    _document = document;
    [self.imgInsurance setImageWithURL:document.documentURL placeholderImage:[UIImage imageNamed:@"icon-insurance"] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    if ([document.validityDate isKindOfClass:[NSDate class]]) {
        self.txtExpirationDate.enabled = NO; //RA-14882
        self.txtExpirationDate.text = [self.formatter stringFromDate:document.validityDate];
        self.dateSelected    = document.validityDate;
        self.datePicker.date = document.validityDate;
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
    
    // Take the photo
    __weak typeof(self) weakSelf = self;
    self.pickerManager = [RAPhotoPickerControllerManager pickerManager];
    [self.pickerManager showPickerControllerFromViewController:self sender:sender allowEditing:YES finishedBlock:^(UIImage *image, NSError *error) {
        if (error) {
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive]];
        } else {
            CGFloat maxArea = 480000;
            image = [UIImage imageWithImage:image scaledToMaxArea:maxArea];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.imgInsurance.image = image;
                [weakSelf enableBtnUpdate:YES];
                weakSelf.photoWasChanged = YES;
            });
        }
    }
    accessDeniedBlock:^(NSString *errorTitle, NSString *errorMessage) {
        [RAAlertManager showAlertWithTitle:errorTitle message:errorMessage];
    }];
}

- (NSDateFormatter*)formatter {
    static NSDateFormatter *formatter;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd/MM/yyyy"];
    }
    return formatter;
}

- (void)dateChanged:(UIDatePicker*)sender {
    self.txtExpirationDate.text = [[self formatter] stringFromDate:sender.date];
    self.dateSelected = sender.date;
    [self enableBtnUpdate:YES];
    self.dateWasChanged = YES;
}

- (void)btSaveUpdateTapped {

    [self enableBtnUpdate:NO];
    if (self.isNewCar && (self.photoWasChanged == NO)) {
        [RAAlertManager showErrorWithAlertItem:[@"Please add your insurance photo" localized] andOptions:[RAAlertOption optionWithState:StateActive]];
        return;
    }
    if (!self.dateSelected) {
        [RAAlertManager showErrorWithAlertItem:[@"Please, select a valid date" localized] andOptions:[RAAlertOption optionWithState:StateActive]];
        return;
    }
    
    BOOL hasDateChangedWithExistingPhoto = self.dateWasChanged && self.document;
    __weak InsuranceDocumentViewController *weakSelf = self;
    dispatch_group_t groupUpload = dispatch_group_create();
    __block NSError *errorUpload;
    [self showHUD];
    if (self.photoWasChanged) {
        dispatch_group_enter(groupUpload);
        
        NSNumber *cityId = [RASessionManager shared].currentSession.driver.cityId;
        [DocumentManager uploadInsurancePhoto:self.imgInsurance.image
                           withExpirationDate:self.dateSelected
                                     forCarId:self.selectedCar.modelID.stringValue
                                     atCityId:cityId
                                   completion:^(NSError *error) {
            errorUpload = error;
            dispatch_group_leave(groupUpload);
        }];
    } else if (hasDateChangedWithExistingPhoto) {
        dispatch_group_enter(groupUpload);
        self.document.validityDate = self.dateSelected;
        
        self.selectedCar.insuranceExpiryDate = self.dateSelected;
        [DocumentManager updateDocument:self.document withCompletion:^(NSError *error) {
            errorUpload = error;
            dispatch_group_leave(groupUpload);
        }];
    }
    
    dispatch_group_notify(groupUpload, dispatch_get_main_queue(), ^{
        
        if (errorUpload){
            [self hideHUD];
            
            if (self.isNewCar) {
                NSMutableString *message = [NSMutableString new];
                [message appendString:errorUpload.localizedDescription];
                [message appendString:@"\n"];
                [message appendString:[@"There was an error trying to upload the insurance information, please try again" localized]];
                
                RAAlertOption *option = [RAAlertOption optionWithState:StateActive];
                [option addAction:[RAAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    [weakSelf performSegueWithIdentifier:@"UnWindCarSelectionViewController" sender:weakSelf];
                }]];
                
                [RAAlertManager showErrorWithAlertItem:message andOptions:option];
                
            } else {
                [RAAlertManager showErrorWithAlertItem:errorUpload andOptions:[RAAlertOption optionWithState:StateActive]];
            }

        } else {
            if (self.isNewCar) {
                [self performSegueWithIdentifier:@"UnWindCarSelectionViewController" sender:weakSelf];
            } else {
                [self showSuccessHUDandPOP];
            }
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
