//
//  TermAndConditionViewController.m
//  RideDriver
//
//  Created by Roberto Abreu on 5/23/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "TermAndConditionViewController.h"

#import "ConfigRegistration.h"
#import "ConfigurationManager.h"
#import "NSDate+Utils.h"
#import "NSString+Utils.h"
#import "RASessionManager.h"
#import "RATerm.h"
#import "RideDriver-Swift.h"
#import "RAAlertManager.h"

NSString *const kNotificationDidAcceptedTermsAndConditions = @"kNotificationDidAcceptedTermsAndConditions";

#define kBtnConfirmEnabled [UIColor colorWithRed:2.0/255.0 green:167.0/255.0 blue:249.0/255.0 alpha:1]
#define kBtnConfirmDisable [UIColor colorWithRed:177.0/255.0 green:180.0/255.0 blue:187.0/255.0 alpha:1]

@interface TermAndConditionViewController ()

@property (weak, nonatomic) IBOutlet UITextView *tvTerms;
@property (weak, nonatomic) IBOutlet UILabel *lblLastUpdate;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *btnContinue;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *aiLoading;

//Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTopVHelpBar;

@end

@implementation TermAndConditionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDesign];
    [self loadData];
}

- (void)setupDesign {
    self.navigationController.navigationBar.accessibilityIdentifier = @"New Terms & Conditions";
    self.scrollView.alpha = 0;
    self.btnContinue.backgroundColor = kBtnConfirmDisable;
    self.btnContinue.enabled = NO;
}

- (void)loadData {
    __weak TermAndConditionViewController *weakSelf = self;
    dispatch_group_t groupApiCalls = dispatch_group_create();
    
    NSNumber *cityId = [RASessionManager shared].currentSession.driver.cityId;
    
    //Load regConfig ~ Used for HelpBar
    dispatch_group_enter(groupApiCalls);
    [NetworkManager getCityDetailWithID:cityId withCompletion:^(RACityDetail *cityDetail, NSError *error) {
        if (!error) {
            weakSelf.regConfig = [ConfigRegistration configWithCity:[ConfigurationManager getRegisteredCity] andDetail:cityDetail];
        }
        dispatch_group_leave(groupApiCalls);
    }];
    
    //Re-Load Config Global ~ To get last updated Terms
    dispatch_group_enter(groupApiCalls);
    __block NSError *apiError;
    [RAConfigAPI getGlobalConfigurationInCityId:cityId completion:^(ConfigGlobal * _Nullable globalConfig, NSError * _Nullable error) {
        if (!error) {
            [ConfigurationManager shared].global = globalConfig;
        }
        
        apiError = error;
        dispatch_group_leave(groupApiCalls);
    }];
    
    dispatch_group_notify(groupApiCalls, dispatch_get_main_queue(), ^{
        
        if (apiError) {
            RAAlertOption *option = [RAAlertOption optionWithState:StateActive];
            [option addAction:[RAAlertAction actionWithTitle:[@"Ok" localized] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nullable action) {
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }]];
            [RAAlertManager showErrorWithAlertItem:apiError andOptions:option];
            return;
        }
        
        //Load Terms
        RATerm *term = [ConfigurationManager shared].global.currentTerms;
        [NetworkManager getDriverTermsAtURL:term.url WithCompletion:^(NSString *termText, NSError *error) {
            if (error) {
                RAAlertOption *option = [RAAlertOption optionWithState:StateActive];
                [option addAction:[RAAlertAction actionWithTitle:[@"Ok" localized] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nullable action) {
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }]];
                [RAAlertManager showErrorWithAlertItem:apiError andOptions:option];
            } else {
                [self.aiLoading stopAnimating];
                
                self.tvTerms.text = termText;
                
                self.lblLastUpdate.text = [NSString stringWithFormat:[@"LAST UPDATE: %@" localized], [term.publication publicationFormat]];
                
                if (self.regConfig) {
                    self.constraintTopVHelpBar.constant = 0;
                }
                
                [UIView animateWithDuration:0.8 animations:^{
                    [self.view layoutIfNeeded];
                    self.scrollView.alpha = 1.0;
                }];
                
            }
        }];
        
    });
    
}

- (IBAction)agreementSelected:(UIButton*)sender {
    sender.selected = !sender.selected;
    self.btnContinue.enabled = sender.selected;
    self.btnContinue.backgroundColor = sender.selected ? kBtnConfirmEnabled : kBtnConfirmDisable;
}

- (IBAction)accepted:(id)sender {
    [self showHUD];
    NSString *termId = [[ConfigurationManager shared].global.currentTerms.modelID stringValue];
    [NetworkManager acceptTermsWithId:termId withCompletion:^(NSError *error) {
        if (error) {
            [self hideHUD];
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive]];
            return;
        }
        [self showSuccessHUDandPOP];
        [RASessionManager shared].currentSession.driver.agreedToLegalTerms = [NSNumber numberWithBool:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidAcceptedTermsAndConditions object:nil];
    }];
}

@end
