//
//  ReferFriendByPhoneViewController.h
//  RideDriver
//
//  Created by Carlos Alcala on 9/14/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "BaseViewController.h"

@interface ReferFriendByPhoneViewController : BaseViewController

//IBOutlets
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextfield;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

//Actions
- (IBAction)phoneAction:(UIButton *)sender;

@end
