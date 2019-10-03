//
//  RAAlertOption.h
//  Ride
//
//  Created by Roberto Abreu on 15/11/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RAAlertConstant.h"
#import "RAAlertAction.h"
@interface RAAlertOption : NSObject

@property (nonatomic) NSString *title;
@property (nonatomic) RAAlertState state;
@property (nonatomic) RAAlertShownOption shownOption;
@property (nonatomic) NSMutableArray<RAAlertAction *> *actions;

+ (instancetype)optionWithTitle:(NSString*)title withState:(RAAlertState)state andShownOption:(RAAlertShownOption)shownOption;

- (instancetype)initWithTitle:(NSString*)title withState:(RAAlertState)state andShownOption:(RAAlertShownOption)shownOption;

#pragma mark - Convenience Initializer
+ (instancetype)optionWithTitle:(NSString*)title;
+ (instancetype)optionWithState:(RAAlertState)state;
+ (instancetype)optionWithShownOption:(RAAlertShownOption)shownOption;
+ (instancetype)optionWithState:(RAAlertState)state andShownOption:(RAAlertShownOption)shownOption;
+ (instancetype)optionWithTitle:(NSString*)title andState:(RAAlertState)state;

#pragma mark - Multiples Buttons
- (void)addAction:(RAAlertAction *)action;

@end
