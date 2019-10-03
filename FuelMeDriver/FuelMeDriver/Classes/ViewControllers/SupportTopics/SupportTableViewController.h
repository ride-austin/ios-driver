//
//  SupportTableViewController.h
//  Ride
//
//  Created by Robert on 7/2/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RASupportTopic.h"

@interface SupportTableViewController : UITableViewController

@property (strong, nonatomic) NSNumber *rideId;
@property (strong, nonatomic) RASupportTopic *parentTopic;
@property (strong, nonatomic) NSArray<RASupportTopic*> *subTopics;

@end
