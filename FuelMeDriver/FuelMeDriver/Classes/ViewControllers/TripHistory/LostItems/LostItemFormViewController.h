//
//  LostItemFormViewController.h
//  Ride
//
//  Created by Theodore Gonzalez on 5/18/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "BaseXLViewController.h"

@class LIOptionDataModel;
@class TripHistoryDataModel;

@interface LostItemFormViewController : BaseXLViewController

- (void)setFormDataModel:(LIOptionDataModel *)formDataModel andRideId:(NSNumber *)rideId;

@end
