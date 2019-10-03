//
//  ReferSelectionViewController.m
//  RideDriver
//
//  Created by Carlos Alcala on 9/13/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "ReferSelectionViewController.h"

#import "ConfigurationManager.h"

@interface ReferSelectionViewController ()

//IBOutlets
@property (weak, nonatomic) IBOutlet UILabel *codeLabel;
@property (weak, nonatomic) IBOutlet UILabel *receiveTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *receiveTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;
@property (weak, nonatomic) IBOutlet UIButton *textButton;

@end

@implementation ReferSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureBasedOnConfig];
}

- (void)configureBasedOnConfig {
    NSAssert(false, @"This is temporarily disabled RA-5170");
    ConfigReferFriend *config   = [ConfigReferFriend new];
    self.navigationItem.title   = config.menuTitle;
    self.emailButton.hidden     = config.isEmailEnabled == NO;
    self.textButton.hidden      = config.isEmailEnabled == NO;
    self.receiveTitleLabel.text = config.header?:@"";
    self.receiveTextLabel.text  = config.body?:@"";
}

@end
