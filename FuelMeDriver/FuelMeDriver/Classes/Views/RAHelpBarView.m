//
//  RAHelpBarView.m
//  Ride
//
//  Created by Theodore Gonzalez on 12/9/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RAHelpBarView.h"

@implementation RAHelpBarView

- (IBAction)btTapped {
    [self.delegate didTapHelpBar];
}

@end
