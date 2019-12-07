//
//  EditViewController.h.m
//  RideAustin
//
//  Created by Tyson Bunch on 9/19/12.
//  Copyright (c) 2012 FuelMe, Inc. All rights reserved.
//

#import "EditViewController.h"

#import "ForgotPasswordViewController.h"
#import "NSString+PhoneUtils.h"
#import "NSString+Utils.h"
#import "NSString+Valid.h"
#import "PhoneNumberFormatter.h"
#import "PinViewController.h"
#import "RASessionManager.h"
#import "RideDriver-Swift.h"
#import "RideDriverConstants.h"
#import "UITextField+Utils.h"
#import "UITextField+Valid.h"
#import "RAAlertManager.h"
#import "RAUserAPI.h"
#import "RAEnvironmentManager.h"

#import "KLCPopup.h"
#import "MRCountryPicker-Swift.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <UIActivityIndicator_for_SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>
@import NSString_RemoveEmoji;

@interface EditViewController ()

//IBOutlets
@property (nonatomic, weak) IBOutlet UITextField* firstNameTextField;
@property (nonatomic, weak) IBOutlet UITextField* lastNameTextField;
@property (nonatomic, weak) IBOutlet UITextField *emailTextField;
@property (nonatomic, weak) IBOutlet UITextField *nickNameTextField;
@property (nonatomic, weak) IBOutlet UITextField* mobileTextField;
@property (nonatomic, weak) IBOutlet UITextField* passwordTextField;
@property (nonatomic, weak) IBOutlet UIImageView *userImageView;
@property (nonatomic, weak) IBOutlet MRCountryPicker *countryPicker;
@property (nonatomic, weak) IBOutlet UIImageView *ivFlag;
@property (nonatomic) IBOutlet UIView *viewCountryPicker;
@property (nonatomic) IBOutlet UIScrollView *scrollViewContainer;

//Properties
@property (assign, nonatomic) UIEdgeInsets previousContentInsent;
@property (assign, nonatomic) UIEdgeInsets previousScrollIndicatorContentInset;
@property (assign, nonatomic) CGSize previousContentSize;
@property (nonatomic) NSString * countryCode;
@property (nonatomic) PhoneNumberFormatter* phoneNumberFormatter;
@property (nonatomic) RAPhotoPickerControllerManager *pickerManager;
@property (nonatomic) UIBarButtonItem *saveButton;
@property (nonatomic) BOOL changePhoneText;

@end

@interface EditViewController (TextFields) <UITextFieldDelegate>
@end

@interface EditViewController (CountryPickerDelegate) <MRCountryPickerDelegate>
@end

@interface EditViewController (PhoneVerificationDelegate) <PhoneVerificationDelegate>

@end

@interface EditViewController (Observers)

- (void)updateForegroundObservers;
- (void)removeForegroundObservers;

@end

@interface EditViewController (Private)

- (void)configureData;
- (void)showAlertToContactSupportFor:(NSString *)targetField;

@end

@implementation EditViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self configureNavigationBar];
    [self addEdgeInsetsToTextFields];
    self.changePhoneText = YES;
    self.previousContentSize = self.scrollViewContainer.contentSize;
    [self configureCountryPicker];
    [self configureData];
    if (@available(iOS 13.0, *)) {
        self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateForegroundObservers];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeForegroundObservers];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Configure UI

- (void)configureNavigationBar {
    self.title = [@"Edit Account" localized];
    
    [self.navigationController setNavigationBarHidden:NO];
    self.saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(attemptToSaveChanges)];
    
    [self.navigationItem setRightBarButtonItem:self.saveButton];
    [self toggleSaveButton:NO];
}

- (void)configureCountryPicker {
    [self.countryPicker setCountryPickerDelegate:self];
    [self.ivFlag.layer setBorderColor: [[UIColor grayColor] CGColor]];
    [self.ivFlag.layer setBorderWidth: 1.0];
}

#pragma mark - IBActions

- (IBAction)didTapFirstName {
    [self showAlertToContactSupportFor:@"first name"];
}
- (IBAction)didTapLastName {
    [self showAlertToContactSupportFor:@"last name"];
}
- (IBAction)didTapEmail {
    [self showAlertToContactSupportFor:@"email"];
}

- (IBAction)didTapChangePhoto:(id)sender {
    [self.view endEditing:YES];
    
    // Take the photo
    __weak typeof(self) weakSelf = self;
    self.pickerManager = [RAPhotoPickerControllerManager pickerManager];
    [self.pickerManager showPickerControllerFromViewController:self sender:sender allowEditing:YES
                                                 finishedBlock:^(UIImage *image, NSError *error) {
        if (error) {
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive]];
        } else {
            if (image) {
                CGFloat maxArea = 480000;
                image = [UIImage imageWithImage:image scaledToMaxArea:maxArea];
            }
            NSData *imageData = [image compressToMaxSize:300000];
            
            [weakSelf showHUD];
            [[RASessionManager shared] updateDriverPhoto:imageData withCompletion:^(NSError * _Nullable error) {
                [weakSelf hideHUD];
                if (error) {
                    [RAAlertManager showErrorWithAlertItem:error
                                                andOptions:[RAAlertOption optionWithState:StateActive]];
                    DBLog(@"Update Photo Error: %@",error);
                } else {
                    [RAAlertManager showAlertWithTitle:[@"Driver Photo" localized]
                                               message:[@"Photo updated successfully" localized]
                                               options:[RAAlertOption optionWithState:StateActive]];
                }
            }];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.userImageView.image = image;
            });
        }
    }
    accessDeniedBlock:^(NSString *errorTitle, NSString *errorMessage) {
        [RAAlertManager showAlertWithTitle:errorTitle message:errorMessage];
    }];
}

- (void)attemptToSaveChanges {
    [self.view endEditing:NO];
    
    NSArray* errors = [self validate];
    if (errors) {
        NSString *errorMessage = [errors objectAtIndex:0];
        [RAAlertManager showErrorWithAlertItem:errorMessage andOptions:[RAAlertOption optionWithState:StateActive]];
        [[errors lastObject] becomeFirstResponder];
    } else {
        [self saveUser];
    }
}

- (void)saveUser {
    RAUserDataModel *user = [RASessionManager shared].currentSession.driver.user;
    
    NSString *newPhone = self.mobileTextField.text;
    BOOL needsVerification = [newPhone isEqualToString:user.phoneNumber] == NO;
    if (needsVerification) {
        __weak EditViewController *weakSelf = self;
        [RAUserAPI checkAvailabilityOfPhone:newPhone withCompletion:^(BOOL failed, NSError *error) {
            if (failed) {
                [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive andShownOption:AllowNetworkError]];
            } else {
                if (![[RAEnvironmentManager sharedManager] isProdServer]) {
                    
                    RAAlertOption *alertOptions = [RAAlertOption optionWithState:StateActive];
                    [alertOptions addAction:[RAAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nullable action) {
                    [weakSelf submitSaveRequestForUser];
                }]];
                       
                    [alertOptions addAction:[RAAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nullable action) {
                        [weakSelf verifyPhoneNumber:newPhone];
                    }]];
                       
                    [RAAlertManager showAlertWithTitle:@"TEST MODE" message:@"Do you want to bypass the pin verification?" options:alertOptions];
                } else {
                    [weakSelf verifyPhoneNumber:newPhone];
                }
            }
        }];
    } else {
        [self submitSaveRequestForUser];
    }
}

- (void)verifyPhoneNumber:(NSString *)phoneNumber {
    [self showHUD];
    [PhoneVerificationAPI postVerifyPhone:phoneNumber completion:^(NSString * _Nullable token, NSError * _Nullable error) {
        [self hideHUD];
        if (token) {
            PinViewController *pVC = [[PinViewController alloc] initWithToken:token mobile:phoneNumber delegate:self];
            [self.navigationController pushViewController:pVC animated:YES];
        } else {
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive]];
        }
    }];
}

- (void)submitSaveRequestForUser {
    __weak __typeof__(self) weakself = self;
    [self showHUD];
    [[RASessionManager shared] updateUserEmail:self.emailTextField.text
                                     firstName:self.firstNameTextField.text
                                      lastName:self.lastNameTextField.text
                                      nickName:self.nickNameTextField.text
                                   phoneNumber:self.mobileTextField.text
                           withCompletionBlock:^(NSError * _Nullable error) {
        [weakself hideHUD];
        if (!error) {
            [RAAlertManager showAlertWithTitle:[@"Profile Updated" localized] message:[@"Your profile has been updated successfully." localized] options:[RAAlertOption optionWithState:StateActive]];
            
            [weakself showProfileVC];
        } else {
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive]];
        }
    }];
}

- (void)showProfileVC {
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[EditViewController class]] ||
            [vc isKindOfClass:[PinViewController class]]) {
            [array removeObject:vc];
        }
    }
    [self.navigationController setViewControllers:array animated:YES];
}

- (NSArray*)validate {
    if([self.emailTextField isEmpty]) {
        return @[[@"Please enter your email address." localized], self.emailTextField];
    } else {
        //RA-1133: Implemented validation category
        if (![self.emailTextField isValidEmail]) {
            return @[[@"Please enter a valid email address." localized], self.emailTextField];
        }
    }
    
    if([self.firstNameTextField isEmpty]) {
        return @[[@"Please enter your firstname." localized], self.firstNameTextField];
    }
    
    if([self.lastNameTextField isEmpty]) {
        return @[[@"Please enter your lastname." localized], self.lastNameTextField];
    }
        
    if([self.mobileTextField isEmpty]) {
        return @[[@"Please enter your phone number." localized], self.mobileTextField];
    }

    if (![self.mobileTextField.text isValidPhoneNumberLength]) {
        return @[[@"Please enter a valid mobile phone number. i.e Minimum 8 digits" localized], self.mobileTextField];
    }

    return nil;
}

/**
 *  @returns YES if anything is changed
 */
- (BOOL)needsToSave {
    BOOL didChange = NO;
    RAUserDataModel *user = [RASessionManager shared].currentSession.driver.user;
    if (![user.firstname isEqualToString:self.firstNameTextField.text]) {
        didChange = YES;
    }
    
    if (![user.lastname isEqualToString:self.lastNameTextField.text]) {
        didChange = YES;
    }
    
    if (![user.nickName isEqualToString:self.nickNameTextField.text]) {
        didChange = YES;
    }
    
    if (![user.phoneNumber isEqualToString:self.mobileTextField.text]) {
        didChange = YES;
    }
    
    return didChange;
}

- (void)toggleSaveButton:(BOOL)enabled {
    self.saveButton.enabled = enabled;
}

- (void)addEdgeInsetsToTextFields {
    [self.emailTextField setLeftPaddingWithSpace:15.0];
    [self.firstNameTextField setLeftPaddingWithSpace:15.0];
    [self.lastNameTextField setLeftPaddingWithSpace:15.0];
    [self.nickNameTextField setLeftPaddingWithSpace:15.0];
    [self.mobileTextField setLeftPaddingWithSpace:15.0];
    [self.passwordTextField setLeftPaddingWithSpace:15.0];
}

#pragma mark - Country Code Picker

- (IBAction)btCountryTapped:(id)sender {
    [self.view endEditing:YES];
    KLCPopup *popupCountryPicker = [KLCPopup popupWithContentView:self.viewCountryPicker
                                                         showType:KLCPopupShowTypeBounceIn
                                                      dismissType:KLCPopupDismissTypeBounceOut
                                                         maskType:KLCPopupMaskTypeDimmed
                                         dismissOnBackgroundTouch:YES
                                            dismissOnContentTouch:NO];
    [popupCountryPicker show];
}

@end

@implementation EditViewController (TextFields)

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self.scrollViewContainer scrollRectToVisible:textField.frame animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.mobileTextField) {
        if (textField.text.length == 0) {
            [self.countryPicker setCountryByPhoneCode:self.countryCode];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.firstNameTextField) {
        [self.lastNameTextField becomeFirstResponder];
    } else if (textField == self.lastNameTextField) {
        [self.nickNameTextField becomeFirstResponder];
    } else if (textField == self.nickNameTextField) {
        [self.mobileTextField becomeFirstResponder];
    } else if (textField == self.mobileTextField) {
        [self attemptToSaveChanges];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *cleanString = [string stringByRemovingEmoji];
    if (textField == self.mobileTextField ) {
        cleanString = [[string componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
        NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:cleanString];
        if ([newText hasCountryCode:self.countryCode]) {
            self.mobileTextField.text = newText;
        }
    } else {
        NSString *resultText = [textField.text stringByReplacingCharactersInRange:range withString:cleanString];
        textField.text = resultText;
    }
    [self toggleSaveButton:self.needsToSave];
    return NO; //changes not caught by this method will be caught by UITextFieldTextDidChangeNotification
}

@end

#pragma mark - CountryPicker Delegate

@implementation EditViewController (CountryPickerDelegate)

- (void)setMobileTextfieldEnabled {
    BOOL enabled = YES;
    UIImage *bg = enabled ? [UIImage imageNamed:@"Field"] : [UIImage imageNamed:@"Field-unactive"];
    self.mobileTextField.background = bg;
    self.mobileTextField.enabled = enabled;
}

- (void)countryPhoneCodePicker:(MRCountryPicker *)picker didSelectCountryWithName:(NSString *)name countryCode:(NSString *)countryCode phoneCode:(NSString *)phoneCode flag:(UIImage *)flag {
    [self.ivFlag setImage:flag];
    if (self.changePhoneText) {
        [self.mobileTextField setText:phoneCode];
        [self setMobileTextfieldEnabled];
    } else {
        self.changePhoneText = YES;
    }
    self.countryCode = phoneCode;
}

@end

#pragma mark - Phone Verification Delegate

@implementation EditViewController (PhoneverificationDelegate)

- (void)phoneVerificationDidSucceed {
    [self.navigationController popViewControllerAnimated:YES];
    [self submitSaveRequestForUser];
}

@end

@implementation EditViewController (Observers)

- (void)updateForegroundObservers {
    __weak __typeof__(self) weakself = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        [weakself toggleSaveButton:weakself.needsToSave];
    }];
}

- (void)removeForegroundObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification*)notification {
    CGRect keyboardFrame = [[[notification userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardFrame = [self.scrollViewContainer convertRect:keyboardFrame fromView:nil];
    
    self.previousContentInsent = self.scrollViewContainer.contentInset;
    self.previousScrollIndicatorContentInset = self.scrollViewContainer.scrollIndicatorInsets;
    
    //Change ScrollView Settings
    CGFloat paddingBottom = 20;
    CGFloat heightForm = self.mobileTextField.bounds.size.height + self.mobileTextField.frame.origin.y + paddingBottom;
    self.scrollViewContainer.contentSize = CGSizeMake(self.scrollViewContainer.contentSize.width, heightForm);
    
    self.scrollViewContainer.contentInset = UIEdgeInsetsMake(self.scrollViewContainer.contentInset.top, self.scrollViewContainer.contentInset.left, keyboardFrame.size.height, self.scrollViewContainer.contentInset.right);
    
    self.scrollViewContainer.scrollIndicatorInsets = UIEdgeInsetsMake(self.scrollViewContainer.scrollIndicatorInsets.top, self.scrollViewContainer.scrollIndicatorInsets.left, keyboardFrame.size.height, self.scrollViewContainer.scrollIndicatorInsets.right);
}

- (void)keyboardWillHide:(NSNotification*)notification {
    //Reset ScrollView Settings
    self.scrollViewContainer.contentInset = self.previousContentInsent;
    self.scrollViewContainer.scrollIndicatorInsets = self.previousScrollIndicatorContentInset;
    self.scrollViewContainer.contentSize = self.previousContentSize;
}

@end

@implementation EditViewController (Private)

- (void)verifyFlagForPhoneNumber:(NSString *)phoneNumber{
    NSString *countryCode = [phoneNumber countryCode];
    self.changePhoneText = NO;
    if (countryCode) {
        [self.countryPicker setCountryByPhoneCode:countryCode];
    }
}

- (void)configureData {
    RADriverDataModel *driver = [RASessionManager shared].currentSession.driver;
    RAUserDataModel *user = driver.user;
    
    self.firstNameTextField.text = user.firstname;
    self.lastNameTextField.text  = user.lastname;
    self.nickNameTextField.text  = user.nickName;
    self.emailTextField.text     = user.email;
    self.mobileTextField.text    = user.phoneNumber;
    self.passwordTextField.text  = @"BOGUS SHIT";
    
    if (driver.photoUrl) {
        [self.userImageView setImageWithURL:driver.photoUrl
                           placeholderImage:[UIImage imageNamed:@"person_placeholder"]
                usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    
    NSString *phone = [user.phoneNumber clearedPhoneNumber];
    if (phone) {
        [self verifyFlagForPhoneNumber:phone];
        if (phone.countryCode == nil) {
            [self showAlertUnrecognizedCountryCode:phone];
            [self.countryPicker setCountry:@"US"];
            self.mobileTextField.text = self.countryCode;
        }
    } else {
        [self.countryPicker setCountry:@"US"];
    }
}

- (void)showAlertUnrecognizedCountryCode:(NSString *)phoneNumber {
    NSString *message = [NSString stringWithFormat:[@"We cannot recognize the country code of %@. Please update your phone number." localized], phoneNumber];
    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:[ConfigurationManager appName]
                                        message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:[@"OK" localized] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        self.mobileTextField.text = self.countryCode;
        [self.mobileTextField becomeFirstResponder];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showAlertToContactSupportFor:(NSString *)targetField {
    NSString *title = [NSString stringWithFormat:@"You need to contact support to change your %@", targetField];
    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Contact support" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self showMessageViewWithRideID:nil];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
