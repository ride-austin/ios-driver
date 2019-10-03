//
//  FlatButton+StyleFacade.h
//  RideDriver
//
//  Created by Roberto Abreu on 27/12/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "FlatButton.h"

@interface FlatButton (StyleFacade)

- (void)applyLoginStyle;
- (void)applyRegisterStyle;

#pragma mark - Trip button Style

- (void)applyDefaultTripButtonStyle;
- (void)applyArrivedStyle;
- (void)applyBeginTripStyle;
- (void)applyEndTripStyle;

@end
