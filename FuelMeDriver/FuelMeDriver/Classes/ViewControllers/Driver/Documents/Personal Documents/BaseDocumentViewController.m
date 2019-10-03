//
//  BaseDocumentViewController.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 1/19/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "BaseDocumentViewController.h"

#import "NSString+Utils.h"
#import "RideDriver-Swift.h"
#import "RAHelpBarView.h"
#import "RAAlertManager.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface BaseDocumentViewController () <RAHelpBarViewDelegate>

@property (weak, nonatomic) IBOutlet RAHelpBarView *vHelpBar;

@end

@implementation BaseDocumentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateHelpBar];
}

- (void)updateHelpBar {
    self.vHelpBar.delegate = self;
    [self.vHelpBar.ivLogo sd_setImageWithURL:self.regConfig.cityDetail.logoURLwhite];
}

- (void)setRegConfig:(ConfigRegistration *)regConfig {
    _regConfig = regConfig;
    [self updateHelpBar];
}

#pragma mark - RAHelpBarViewDelegate

- (void)didTapHelpBar {
    [self showMessageViewWithRideID:nil];
}

#pragma mark - Utils

- (BOOL)isImageValid:(UIImage *)image {
    if (image && [image imageValidSizeForMinArea:190*250]) {
        return YES;
    } else {
        [RAAlertManager showErrorWithAlertItem:[@"Please upload a High Quality Photo with a minimum size of 190x250 pixels to be readable." localized] andOptions:[RAAlertOption optionWithTitle:[@"Invalid Size" localized] andState:StateActive]];
        return NO;
    }
}

@end
