//
//  DriverCarInformationViewController.h
//  Ride
//
//  Created by Roberto Abreu on 17/11/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "BaseDocumentViewController.h"

@interface DriverCarInformationViewController : BaseDocumentViewController

@property (nonatomic, strong) NSMutableDictionary *userData;
@property (weak, nonatomic) IBOutlet UIView *vContainer;
@property (weak, nonatomic) IBOutlet UITableView *tblVehicleInformation;

@end
