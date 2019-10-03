//
//  RAAlertOption.m
//  Ride
//
//  Created by Roberto Abreu on 15/11/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RAAlertOption.h"

@implementation RAAlertOption

+ (instancetype)optionWithTitle:(NSString *)title withState:(RAAlertState)state andShownOption:(RAAlertShownOption)shownOption {
    return [[self alloc] initWithTitle:title withState:state andShownOption:shownOption];
}

- (instancetype)initWithTitle:(NSString *)title withState:(RAAlertState)state andShownOption:(RAAlertShownOption)shownOption {
    if (self = [super init]) {
        self.title = title;
        self.state = state;
        self.shownOption = shownOption;
        self.actions = [NSMutableArray new];
    }
    return self;
}

#pragma mark - Convenience Initializer

+ (instancetype)optionWithTitle:(NSString*)title {
    return [[self alloc] initWithTitle:title withState:StateAll andShownOption:None];
}

+ (instancetype)optionWithState:(RAAlertState)state {
    return [[self alloc] initWithTitle:nil withState:state andShownOption:None];
}

+ (instancetype)optionWithShownOption:(RAAlertShownOption)shownOption {
    return [[self alloc] initWithTitle:nil withState:StateAll andShownOption:shownOption];
}

+ (instancetype)optionWithState:(RAAlertState)state andShownOption:(RAAlertShownOption)shownOption {
    return [[self alloc] initWithTitle:nil withState:state andShownOption:shownOption];
}

+ (instancetype)optionWithTitle:(NSString*)title andState:(RAAlertState)state {
    return [[self alloc] initWithTitle:title withState:state andShownOption:None];
}

#pragma mark - Multiples buttons

- (void)addAction:(RAAlertAction *)action {
    [self.actions addObject:action];
}

@end
