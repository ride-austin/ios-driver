//
//  ActionView.h
//  RideDriver
//
//  Created by Carlos Alcala on 11/15/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ActionViewDefines.h"
#import "FlatButton+StyleFacade.h"

@interface ActionView : UIView

//IBOutlets
@property (weak, nonatomic) IBOutlet FlatButton *btnTrip;

//Properties
@property (nonatomic, weak) id<ActionViewDelegate> delegate;
@property (nonatomic, assign) ActionType currentAction;

//Methods
- (void)toggleNextAction:(ActionType)nextAction;

//Actions
- (IBAction)actionButtonPressed:(UIButton *)sender;

@end
