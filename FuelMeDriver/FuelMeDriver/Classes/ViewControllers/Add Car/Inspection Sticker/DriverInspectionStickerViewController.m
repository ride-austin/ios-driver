//
//  DriverInspectionStickerViewController.m
//  Ride
//
//  Created by Roberto Abreu on 9/12/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "DriverInspectionStickerViewController.h"

#import "DocumentManager.h"
#import "MakeViewController.h"
#import "NSString+Utils.h"
#import "RAInspectionStickerDetail.h"
#import "UICustomDatePicker.h"
#import "RAAlertManager.h"

#import "KLCPopup.h"
#import <UIActivityIndicator_for_SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>

@interface DriverInspectionStickerViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imgInspectionSticker;
@property (nonatomic) UIImage *stickerImageSelected;
@property (strong, nonatomic) RAPhotoPickerControllerManager *pickerManager;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UITextView *lblContent;
@property (weak, nonatomic) IBOutlet UITextField *txtExpirationDate;
@property (strong,nonatomic) IBOutlet UICustomDatePicker *datePicker;
@property (nonatomic) KLCPopup *datePopup;
@property (nonatomic) NSDate *dateSelected;
@property (nonatomic) BOOL photoWasChanged;
@property (nonatomic) BOOL expirationDateWasChanged;
@property (nonatomic) RADocument *document;

@end

@implementation DriverInspectionStickerViewController

- (instancetype)initWithYear:(NSString*)year userData:(NSMutableDictionary*)userData andRegConfig:(ConfigRegistration*)regConfig {
    if (self = [super init]) {
        self.yearSelected = year;
        self.userData = userData;
        self.regConfig = regConfig;
        self.car = nil;
    }
    return self;
}

- (instancetype)initWithCar:(Car *)car andRegConfig:(ConfigRegistration *)regConfig {
    if (self = [super init]) {
        self.car = car;
        self.regConfig = regConfig;
        self.userData = nil;
        self.yearSelected = nil;
    }
    return self;
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureDatePicker];
    [self configureUI];
    if (self.car) {
        [self configureExistingData];
    }
}

- (void)setDateSelected:(NSDate *)dateSelected {
    _dateSelected = dateSelected;
    self.txtExpirationDate.text = [[self formatter] stringFromDate:dateSelected];
    self.expirationDateWasChanged = YES;
    [self enableBtnUpdate:YES];
}

- (void)configureDatePicker {
    self.datePicker.minDate = [NSDate date];
    self.datePicker.maxDate = [NSDate dateWithTimeIntervalSinceNow:60*60*24*365*20];
    self.datePicker.currentDate = [NSDate date];
    self.datePicker.order = NSCustomDatePickerOrderMonthDayAndYear;
    self.datePicker.option = NSCustomDatePickerOptionLongMonth | NSCustomDatePickerOptionYear;
    [self.datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    [self.datePicker setBackgroundColor:[UIColor whiteColor]];
}

- (void)dateChanged:(UICustomDatePicker *)sender{
    self.dateSelected = sender.currentDate;
}

- (void)configureUI {
    
    RAInspectionStickerDetail *inspectionSticker = self.regConfig.cityDetail.inspectionSticker;
    
    self.title = inspectionSticker.navBarTitle;
    self.lblTitle.text = inspectionSticker.title;
    self.lblContent.text = inspectionSticker.content;
    
    //Setup Righ BarButtonItem
    NSString *btnTitle = self.car ? [@"UPDATE" localized] : [@"NEXT" localized];
    SEL action = self.car ? @selector(updatePressed) : @selector(nextPressed);
    UIBarButtonItem *btnRightItem = [[UIBarButtonItem alloc] initWithTitle:btnTitle style:UIBarButtonItemStylePlain target:self action:action];
    self.navigationItem.rightBarButtonItem = btnRightItem;
    [self enableBtnUpdate:NO];
    
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
}

- (void)configureExistingData {
    [self showHUD];
    __weak DriverInspectionStickerViewController *weakSelf = self;
    [DocumentManager getInspectionStickerWithCarId:self.car.modelID.stringValue completion:^(RADocument *document, NSError *error) {
        [weakSelf hideHUD];
        if (error) {
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithShownOption:AllowNetworkError]];
        } else if (document && document.documentURL) {
            weakSelf.document = document;
            [weakSelf.imgInspectionSticker setImageWithURL:document.documentURL placeholderImage:[UIImage imageNamed:@"icon-inspection-sticker"] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            
            if (document.validityDate) {
                weakSelf.dateSelected = document.validityDate;
                weakSelf.datePicker.currentDate = document.validityDate;
            }
        }
    }];
}

- (NSDateFormatter*)formatter {
    static NSDateFormatter *formatter;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM/yyyy"];
    }
    return formatter;
}

- (IBAction)takePhotoPressed:(id)sender {
    [self.view endEditing:YES];
    
    __weak DriverInspectionStickerViewController *weakSelf = self;
    self.pickerManager = [RAPhotoPickerControllerManager pickerManager];
    [self.pickerManager showPickerControllerFromViewController:self sender:sender allowEditing:YES finishedBlock:^(UIImage *image, NSError *error) {
        if (error) {
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive]];
        } else {
            BOOL valid = [weakSelf isImageValid:image];
            if (valid) {
                CGFloat maxArea = 480000;
                image = [UIImage imageWithImage:image scaledToMaxArea:maxArea];
            }
            
            weakSelf.stickerImageSelected = valid ? image : nil;
            weakSelf.imgInspectionSticker.image = valid ? image : nil;
            weakSelf.photoWasChanged = valid;
            [weakSelf enableBtnUpdate:valid];
        }
    } accessDeniedBlock:^(NSString *errorTitle, NSString *errorMessage) {
        [RAAlertManager showAlertWithTitle:errorTitle message:errorMessage];
    }];
}

#pragma mark - Car Creation flow

- (void)nextPressed {
    
    if ([self validateForm]) {
        self.userData[@"inspectionSticker"] = self.stickerImageSelected;
        self.userData[@"inspectionStickerExpirationDate"] = self.dateSelected;
        [self.navigationController pushViewController:[[MakeViewController alloc] initWithYear:self.yearSelected] animated:YES];
    }
    
}

#pragma  mark - Update Inspection Sticker Car

- (void)updatePressed {
    if ([self validateForm]) {
        [self showHUD];
        
        if (self.photoWasChanged) {
            NSNumber *cityId = [RASessionManager shared].currentSession.driver.cityId;
            [DocumentManager uploadInspectionSticker:self.stickerImageSelected withExpirationDate:self.dateSelected atCityId:cityId withCarId:self.car.modelID.stringValue completion:^(NSError *error) {
                if (error) {
                    [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive]];
                } else {
                    [self showSuccessHUDandPOP];
                }
            }];
        } else if (self.expirationDateWasChanged && self.document) {
            self.document.validityDate = self.dateSelected;
            [DocumentManager updateDocument:self.document withCompletion:^(NSError *error) {
                if (error) {
                    [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive]];
                } else {
                    [self showSuccessHUDandPOP];
                }
            }];
        }
    }
}

#pragma mark - Common Util

- (BOOL)validateForm {
    if (![[NetworkManager sharedInstance] isNetworkReachable]) {
        [RAAlertManager showErrorWithAlertItem:[@"Internet Connection is down. Please try again later." localized]
                                    andOptions:[RAAlertOption optionWithTitle:[@"Network Offline" localized] andState:StateActive]];
        return NO;
    }
    
    BOOL isPhototForUpdateCarNotValid = (self.car && !self.document && !self.stickerImageSelected);
    BOOL isPhotoForNewCarNotValid = !self.car && !self.stickerImageSelected;
    
    if (isPhototForUpdateCarNotValid || isPhotoForNewCarNotValid) {
        [RAAlertManager showErrorWithAlertItem:[@"Please upload your Inspection Sticker Photo to continue." localized]
                                    andOptions:[RAAlertOption optionWithTitle:[@"Inspection Sticker" localized] andState:StateActive]];
        return NO;
    }
    
    if (!self.dateSelected) {
        [RAAlertManager showErrorWithAlertItem:[@"Please, select a valid expiration date." localized]
                                    andOptions:[RAAlertOption optionWithTitle:[@"Inspection Sticker" localized] andState:StateActive]];
        return NO;
    }
    
    return YES;
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
