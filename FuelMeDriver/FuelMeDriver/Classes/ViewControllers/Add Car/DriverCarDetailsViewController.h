//
//  DriverCarDetailsViewController.h
//  Ride
//
//  Created by Abdul Rehman on 16/05/2016.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "BaseDocumentViewController.h"
#import "Car.h"

@interface DriverCarDetailsViewController : BaseDocumentViewController

@property(nonatomic,strong) IBOutlet UITextView *carDescription;

- (id)initWithUserData:(NSMutableDictionary*)userData andRegistrationConfig:(ConfigRegistration *)regConfig;

@end
