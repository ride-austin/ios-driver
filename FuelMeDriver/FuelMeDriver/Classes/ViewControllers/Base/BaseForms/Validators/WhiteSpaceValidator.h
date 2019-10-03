//
//  WhiteSpaceValidator.h
//  Ride
//
//  Created by Theodore Gonzalez on 6/6/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <XLForm/XLForm.h>

@interface WhiteSpaceValidator : XLFormValidator
+(XLFormValidator *)validatorWithMessage:(NSString *)message;
@end
