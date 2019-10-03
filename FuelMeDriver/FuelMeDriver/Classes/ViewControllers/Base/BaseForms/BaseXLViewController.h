//
//  BaseXLViewController.h
//  Ride
//
//  Created by Theodore Gonzalez on 5/18/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "NSObject+className.h"
#import "UIViewController+progressHUD.h"
#import "XLFormRowDescriptor+factory.h"

#import <XLForm/XLForm.h>

@interface BaseXLViewController : XLFormViewController

@end
@interface BaseXLViewController (validation)
- (BOOL)isFormValid;
@end
