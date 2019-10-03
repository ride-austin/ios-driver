//
//  DriverTNCBackSideViewController.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 1/19/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "DriverTNCBackSideViewController.h"

#import "DocumentManager.h"
#import "NSString+Utils.h"
#import "RAAlertManager.h"

#import "KLCPopup.h"

@interface DriverTNCBackSideViewController ()

@property (weak, nonatomic) IBOutlet UIView *vImages;
@property (weak, nonatomic) IBOutlet UIImageView *ivTncCard;
@property (weak, nonatomic) IBOutlet UIView *vCircle;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle1;
@property (weak, nonatomic) IBOutlet UILabel *lbSubtitle1;
@property (weak, nonatomic) IBOutlet UILabel *lbCallToAction;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle2;
@property (weak, nonatomic) IBOutlet UITextView *tvSubtitle2;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *vTableHeader;
@property (weak, nonatomic) IBOutlet UILabel *lblExpiration;
@property (weak, nonatomic) IBOutlet UITextField *txtExpirationDate;
@property (weak, nonatomic) IBOutlet UIButton *btTakePhoto;

@property (nonatomic) UIImage *imgFront;
@property (nonatomic) RAPhotoPickerControllerManager *pickerManager;
@property (strong, nonatomic) UIBarButtonItem *btSave;

@property (strong,nonatomic) UIDatePicker *datePicker;
@property (nonatomic) KLCPopup *datePopup;
@property (nonatomic) NSDate *dateSelected;
@property (nonatomic, assign) BOOL dateWasChanged;

@end

@implementation DriverTNCBackSideViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureRightBarButton];
    [self configureLayout];
    [self configureText];
    [self configureData];
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
    }
}

- (void)configureRightBarButton {
    NSString *title = [@"SAVE" localized];
    self.btSave = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:@selector(btSaveTapped:)];
    self.btSave.enabled = NO;
    self.navigationItem.rightBarButtonItem = self.btSave;
}

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
    self.lbTitle1.text          = tnc.title1Back;
    self.lbSubtitle1.text       = tnc.text1Back;
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
    self.txtExpirationDate.text = [[DocumentManager displayDateFormatter] stringFromDate:self.validityDate];
    self.dateSelected = self.validityDate;
    self.datePicker.date = self.validityDate;
}

#pragma mark - Images

- (void)setImgFront:(UIImage *)imgFront {
    _imgFront = imgFront;
    [self updateUIBasedOnInput];
}

- (void)updateUIBasedOnInput {
    self.vImages.hidden = !self.imgFront;
    self.ivTncCard.image = self.imgFront;
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

- (void)btSaveTapped:(UIBarButtonItem *)sender {
    if (self.isInputInvalid) {
        [self.delegate backSideSaved:self.imgFront expirationDate:self.dateSelected];
    }
}

- (void)dateChanged:(UIDatePicker*)sender {
    self.txtExpirationDate.text = [[DocumentManager displayDateFormatter] stringFromDate:sender.date];
    self.dateSelected = sender.date;
    self.dateWasChanged = YES;
    
    [self updateUIBasedOnInput];
}

#pragma mark - Validation

/**
 *  @returns error message if invalid
 */
- (BOOL)isInputInvalid {
    if (self.imgFront == nil) {
        [RAAlertManager showErrorWithAlertItem:self.regConfig.cityDetail.tnc.text1Back andOptions:[RAAlertOption optionWithState:StateActive]];
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
    }
    return isValid ? image : nil;
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
