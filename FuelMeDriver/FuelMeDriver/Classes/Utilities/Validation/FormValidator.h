//
//  FormValidator.h
//  Ride
//
//  Created by Theodore Gonzalez on 8/2/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TFType) {
    TFTypeLicensePlate,
    TFTypeTip
};

@interface FormValidator : NSObject <UITextFieldDelegate>

+ (instancetype)validatorWithType:(TFType)type;
+ (instancetype)tipValidatorWithMax:(NSNumber *)maxTip;
- (BOOL)isValid:(NSString *)text;

@end
