//
//  PinViewController.h
//  Ride
//
//  Created by Tyson Bunch on 5/11/16.
//  Copyright (c) 2015 FuelMe LLC. All rights reserved.
//

#import "BaseViewController.h"

@protocol PhoneVerificationDelegate <NSObject>

- (void) phoneVerificationDidSucceed;

@end

@interface PinViewController : BaseViewController

@property (nonatomic, weak) id <PhoneVerificationDelegate> delegate;
@property (nonatomic, weak) IBOutlet UITextField *oneTimePinField;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIButton *btnResendText;

- (id)initWithToken:(NSString *)token mobile:(NSString *)mobile delegate:(id<PhoneVerificationDelegate>)delegate;
- (IBAction)resendText:(id)sender;
- (IBAction)changeMobile:(id)sender;

@end
