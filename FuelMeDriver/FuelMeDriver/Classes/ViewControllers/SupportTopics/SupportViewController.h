//
//  SupportViewController.h
//  Ride
//
//  Created by Robert on 7/2/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "BaseViewController.h"
#import "RASupportTopic.h"

@interface SupportViewController : BaseViewController

@property (strong, nonatomic) NSNumber *rideId;
@property (strong, nonatomic) RASupportTopic *selectedSupportTopic;

@end
