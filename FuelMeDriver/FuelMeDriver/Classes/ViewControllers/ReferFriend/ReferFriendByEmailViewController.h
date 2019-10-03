//
//  ReferFriendByEmailViewController.h
//  RideDriver
//
//  Created by Carlos Alcala on 9/14/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "BaseViewController.h"

@interface ReferFriendByEmailViewController : BaseViewController

//IBOutlets
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailTextfield;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;

//Actions
- (IBAction)emailAction:(UIButton *)sender;

@end
