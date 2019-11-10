//
//  DriverTNCViewController.m
//  Ride
//
//  Created by Theodore Gonzalez on 12/8/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//
#import "DriverTNCViewController.h"

#import "DocumentManager.h"
#import "DriverTNCBackSideViewController.h"
#import "UIImage+Ride.h"
#import "UIImage+Utils.h"
#import "NSString+Utils.h"
#import "RAAlertManager.h"

#import "KLCPopup.h"
#import <UIActivityIndicator_for_SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>

@interface DriverTNCViewController () <BackSideDelegate>

@property (weak, nonatomic) IBOutlet UIView *vImages;
@property (weak, nonatomic) IBOutlet UIImageView *ivTncCard;
@property (weak, nonatomic) IBOutlet UIView *vCircle;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle1;
@property (weak, nonatomic) IBOutlet UITextView *tvSubtitle1;
@property (weak, nonatomic) IBOutlet UILabel *lbCallToAction;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle2;
@property (weak, nonatomic) IBOutlet UITextView *tvSubtitle2;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *vTableHeader;
@property (weak, nonatomic) IBOutlet UILabel *lblExpiration;
@property (weak, nonatomic) IBOutlet UITextField *txtExpirationDate;
@property (weak, nonatomic) IBOutlet UIButton *btTakePhoto;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBottomSpaceBtTakePhoto;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBottomLblExpirationDate;

@property (nonatomic) UIImage *imgFront;
@property (nonatomic) RAPhotoPickerControllerManager *pickerManager;
@property (strong, nonatomic) UIBarButtonItem *btSave;
@property (nonatomic, assign) BOOL imgFrontWasChanged;

@property (strong,nonatomic) UIDatePicker *datePicker;
@property (nonatomic) KLCPopup *datePopup;
@property (nonatomic) NSDate *dateSelected;
@property (nonatomic, assign) BOOL dateWasChanged;

@property (nonatomic) RADocument *document;

@end

@implementation DriverTNCViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
//  [self configureRightBarButton]; RA-14882
    [self configureLayout];
    [self configureText];
    [self configureData];
}

- (UIUserInterfaceStyle)overrideUserInterfaceStyle {
    return UIUserInterfaceStyleLight;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (!self.tableView.tableHeaderView) {
        self.vTableHeader.frame = CGRectMake(0,0,self.tableView.bounds.size.width,CGFLOAT_MAX);
        CGRect headerFrame = [self.vTableHeader bounds];
        [self.vTableHeader setNeedsLayout];
        [self.vTableHeader layoutIfNeeded];
        CGFloat finalHeight = [self.vTableHeader systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        headerFrame.size.height = finalHeight;
        self.vTableHeader.frame = headerFrame;
        self.tableView.tableHeaderView = self.vTableHeader;
        self.tableView.tableHeaderView.userInteractionEnabled = YES;
    }
}

//- (void)configureRightBarButton {
//    NSString *title = self.regConfig.cityDetail.tnc.needsBackPhoto ? [@"NEXT" localized] : [@"SAVE" localized];
//    self.btSave = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:@selector(btSaveTapped:)];
//    self.btSave.enabled = NO;
//    self.navigationItem.rightBarButtonItem = self.btSave;
//}

- (void)configureLayout {
    self.vImages.hidden = YES;
    self.vCircle.layer.cornerRadius = 27.0;
    self.btTakePhoto.layer.cornerRadius = 22.5;
    
    CGFloat padding = -self.tvSubtitle2.textContainer.lineFragmentPadding;
    self.tvSubtitle2.textContainerInset = UIEdgeInsetsMake(0,padding,0,padding);
    self.tableView.separatorColor = [UIColor clearColor];
    
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
    
    BOOL needsBackPhoto = NO; //self.regConfig.cityDetail.tnc.needsBackPhoto //RA-14882
    if (needsBackPhoto){
        self.lblExpiration.hidden = YES;
        self.txtExpirationDate.hidden = YES;
        self.constraintBottomLblExpirationDate.constant = -45.0;
    }
    
    //Setup Date Picker
    self.datePicker = [[UIDatePicker alloc] init];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    self.datePicker.minimumDate = [NSDate new];
    self.datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [self.datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    [self.datePicker setBackgroundColor:[UIColor whiteColor]];

    [self updateUIBasedOnInput];
}

- (void)configureText {
    TNCScreenDetail *tnc = self.regConfig.cityDetail.tnc;
    self.title                  = tnc.headerText;
    self.lbTitle1.text          = tnc.title1;
    self.tvSubtitle1.text       = tnc.text1;
    self.lbCallToAction.text    = tnc.actionText1;
    self.lbTitle2.text          = tnc.title2;
    NSString *stringHTML        = [NSString stringWithFormat:@"<span style=\"font-family: Montserrat-Light; font-size: 14; color:#3C4350\">%@</span>",tnc.text2];
    NSData *dataHTML            = [stringHTML dataUsingEncoding:NSUnicodeStringEncoding];
    NSDictionary *options = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};
    NSAttributedString *attributedString
    = [[NSAttributedString alloc] initWithData:dataHTML
                                       options:options
                            documentAttributes:nil
                                         error:nil];
    self.tvSubtitle2.attributedText = attributedString;
    [self.btTakePhoto setTitle:[@"TAKE PHOTO" localized] forState:UIControlStateNormal];
}

- (void)configureData {
    __weak DriverTNCViewController *weakSelf = self;
    [DocumentManager getChauffeurLicenseWithCompletion:^(RADocument *document, NSError *error) {
        if (error) {
            RAAlertOption *option = [RAAlertOption optionWithState:StateActive];
            [option addAction:[RAAlertAction actionWithTitle:[@"Ok" localized] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }]];
            
            [RAAlertManager showErrorWithAlertItem:error andOptions:option];
        } else {
            weakSelf.document       = document;
        }
    }];
}

- (void)setDocument:(RADocument *)document {
    _document = document;
    [self.ivTncCard setImageWithURL:document.documentURL usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    if ([document.validityDate isKindOfClass:[NSDate class]]) {
        self.txtExpirationDate.text = [[DocumentManager displayDateFormatter] stringFromDate:document.validityDate];
        self.dateSelected           = document.validityDate;
        self.datePicker.date        = document.validityDate;
    } else {
        //hide when not provided
        self.lblExpiration.hidden = YES;
        self.txtExpirationDate.hidden = YES;
        self.constraintBottomLblExpirationDate.constant = -45.0;
        
        NSDate *today = [NSDate date];
        self.txtExpirationDate.text = [[DocumentManager displayDateFormatter] stringFromDate:today];
        self.dateSelected           = today;
        self.datePicker.date        = today;
    }
    self.constraintBottomSpaceBtTakePhoto.constant = -70; //RA-14882
    [self updateUIBasedOnInput];
}

#pragma mark - Images

- (void)setImgFront:(UIImage *)imgFront {
    _imgFront = imgFront;
    [self updateUIBasedOnInput];
}

- (void)updateUIBasedOnInput {
    if (self.imgFront) {
        self.vImages.hidden  = NO;
        self.ivTncCard.image = self.imgFront;
    } else {
        self.vImages.hidden  = self.document == nil;
    }
    self.btSave.enabled = self.imgFront != nil || self.dateWasChanged;
}

#pragma mark - Actions

- (IBAction)btTakePhotoTapped:(UIButton *)sender {
    __weak __typeof__(self) weakSelf = self;
    self.pickerManager = [RAPhotoPickerControllerManager pickerManager];
    [self.pickerManager showPickerControllerFromViewController:self sender:sender allowEditing:YES finishedBlock:^(UIImage *picture, NSError *error) {
        if (error) {
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive]];
        } else {
            weakSelf.imgFront = [weakSelf validatedImage:picture];
        }
    }
    accessDeniedBlock:^(NSString *errorTitle, NSString *errorMessage) {
        [RAAlertManager showAlertWithTitle:errorTitle message:errorMessage];
    }];
}

- (IBAction)didTapPlaceholderImage:(UIButton *)sender {
    [RAAlertManager showAlertWithTitle:[ConfigurationManager appName] message:@"Please send an email to documents@rideaustin.com"];
}

- (void)dateChanged:(UIDatePicker*)sender {
    self.txtExpirationDate.text = [[DocumentManager displayDateFormatter] stringFromDate:sender.date];
    self.dateSelected = sender.date;
    self.dateWasChanged = YES;
    [self updateUIBasedOnInput];
}

- (void)btSaveTapped:(UIBarButtonItem *)sender {
    if (self.isInputInvalid) {
        if (self.regConfig.cityDetail.tnc.needsBackPhoto) {
            [self showTNCBackSideController];
        } else {
            if (self.document && self.dateWasChanged && !self.imgFrontWasChanged) {
                self.document.validityDate = self.dateSelected;
                [self updateDocument:self.document];
            } else {
                [self uploadChauffeurLicense:self.imgFront];
            }
        }
    }
}

- (void)updateDocument:(RADocument *)document {
    [self showHUD];
    [DocumentManager updateDocument:document withCompletion:^(NSError *error) {
        if (error) {
            [self hideHUD];
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive]];
        } else {
            __weak __typeof__(self) weakself = self;
            [self showSuccessHUDWithCompletion:^{
                [weakself goBackToDocumentMenu];
            }];
        }
    }];
}

- (void)uploadChauffeurLicense:(UIImage *)chauffeurLicense {
    [self showHUD];
    NSNumber *cityId = [RASessionManager shared].currentSession.driver.cityId;
    [DocumentManager uploadChauffeurLicense:chauffeurLicense withExpirationDate:self.dateSelected atCityId:cityId completion:^(NSError *error) {
        if (error) {
            [self hideHUD];
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive]];
        } else {
            __weak __typeof__(self) weakself = self;
            [self showSuccessHUDWithCompletion:^{
                [weakself goBackToDocumentMenu];
            }];
        }
    }];
}

- (void)goBackToDocumentMenu {
    NSArray *vcs = self.navigationController.viewControllers;
    NSMutableArray *mArray = vcs.mutableCopy;
    for (UIViewController *vc in vcs) {
        if ([vc isKindOfClass:[DriverTNCViewController class]] || [vc isKindOfClass:[DriverTNCBackSideViewController class]]) {
            [mArray removeObject:vc];
        }
    }
    [self.navigationController setViewControllers:mArray];
}

#pragma mark - Validation

/**
 *  @returns error message if invalid
 */
- (BOOL)isInputInvalid {
    if (self.document == nil && self.imgFront == nil) {
        [RAAlertManager showErrorWithAlertItem:self.regConfig.cityDetail.tnc.text1 andOptions:[RAAlertOption optionWithState:StateActive]];
        return NO;
    }
    return YES;
}

/**
 *  @returns nil and shows error message if invalid
 */
- (UIImage *)validatedImage:(UIImage *)image {
    BOOL isValid = [super isImageValid:image];
    if (isValid) {
        CGFloat maxArea = 480000;
        image = [UIImage imageWithImage:image scaledToMaxArea:maxArea];
        self.imgFrontWasChanged = YES;
    }
    return isValid ? image : nil;
}

#pragma mark - BackSide

- (void)showTNCBackSideController {
    DriverTNCBackSideViewController *vc = [DriverTNCBackSideViewController new];
    vc.regConfig = self.regConfig;
    vc.delegate = self;
    vc.validityDate = self.dateSelected;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - BackSideDelegate

- (void)backSideSaved:(UIImage *)backSideImage expirationDate:(NSDate *)expirationDate {
    UIImage *combined = [self.imgFront combineWithImage:backSideImage];
    UIImage *tncCard = combined ?: backSideImage;
    
    self.dateSelected = expirationDate;
    [self uploadChauffeurLicense:tncCard];
}

#pragma mark - UITextfield Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.txtExpirationDate) {
        [self.view endEditing:YES];
        self.datePopup = [KLCPopup popupWithContentView:self.datePicker showType:KLCPopupShowTypeBounceIn dismissType:KLCPopupDismissTypeBounceOut maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
        [self.datePopup show];
    }
}
- (IBAction)didTapDummyButton:(id)sender {
    DBLog(@"didTapDummyButton");
}

@end
