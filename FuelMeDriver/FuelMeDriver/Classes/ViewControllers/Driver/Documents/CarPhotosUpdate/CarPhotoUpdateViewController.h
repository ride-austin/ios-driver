//
//  DriverCarBackViewController.h
//  Ride
//
//  Created by Carlos Alcala on 9/21/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "BaseViewController.h"
#import "CarPhotoUpdate.h"

@interface CarPhotoUpdateViewController : BaseViewController

@property (nonatomic, weak) IBOutlet UIImageView *imagePhoto;
@property (nonatomic, strong) UIImage *photo;
@property (nonatomic, strong) CarPhotoUpdate * carPhoto;
@property (nonatomic, strong) NSString * carID;
@property (nonatomic, strong) UIBarButtonItem *saveButton;

- (id)initWithUserData:(NSDictionary*)userData;

- (IBAction)takePhotoAction:(id)sender;

@end
