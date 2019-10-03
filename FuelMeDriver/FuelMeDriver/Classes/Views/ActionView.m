//
//  ActionView.m
//  RideDriver
//
//  Created by Carlos Alcala on 11/15/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "ActionView.h"

@implementation ActionView

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self addSubview:
         [[[NSBundle mainBundle] loadNibNamed:@"ActionView"
                                        owner:self
                                      options:nil] objectAtIndex:0]];
        
        [self initializeView];
    }
    return self;
}

-  (id)initWithFrame:(CGRect)aRect {
    if (self = [super initWithFrame:aRect]) {
        [self addSubview:
         [[[NSBundle mainBundle] loadNibNamed:@"ActionView"
                                        owner:self
                                      options:nil] objectAtIndex:0]];
        
        [self initializeView];
    }
    
    return self;
}

#pragma mark - Internal methods

- (void)initializeView {
    self.backgroundColor = [UIColor clearColor];
    self.btnTrip.alpha = 0.0;
    self.currentAction = Idle;
    [self applyButtonStyleByAction:self.currentAction];
}

- (void)applyButtonStyleByAction:(ActionType)action {
    switch (action) {
        case Arrived:
            [self.btnTrip applyArrivedStyle];
            break;
        case Begin:
            [self.btnTrip applyBeginTripStyle];
            break;
        case End:
            [self.btnTrip applyEndTripStyle];
            break;
        case Idle:
        default:
            [self.btnTrip applyDefaultTripButtonStyle];
            break;
    }
}

- (NSString*)toString:(ActionType)action {
    switch (action) {
        case Arrived:
            return @"Arrived";
        case Begin:
            return @"Begin";
        case End:
            return @"End";
        case Idle:
            return @"Idle";
        default:
            return @"";
    }
}

- (IBAction)actionButtonPressed:(UIButton *)sender {
    if (self.delegate) {
        [self.delegate actionViewDidTap:sender withAction:self.currentAction];
    }
}

- (void)toggleNextAction:(ActionType)nextAction{
    if (self.currentAction == nextAction) {
        return;
    }
    self.currentAction = nextAction;
    self.btnTrip.alpha = self.currentAction == Idle ? 0.0 : 1.0;
    [self applyButtonStyleByAction:nextAction];
}

@end
