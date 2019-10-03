//
//  DriverCarFrontViewController.h
//  Ride
//
//  Created by Roberto Abreu on 12/26/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "BaseDocumentViewController.h"

@interface DriverCarPhotoViewController : BaseDocumentViewController

@property (weak, nonatomic) IBOutlet UITextView *lblDescription;
@property (weak, nonatomic) IBOutlet UIImageView *imagePhoto;
@property (weak, nonatomic) UIImage *photo;
@property (strong, nonatomic) NSMutableDictionary *userData;

- (id)initWithUserData:(NSMutableDictionary*)userData registrationConfig:(ConfigRegistration *)regConfig carPhotoType:(CarPhotoType)carPhotoType;

- (IBAction)takePhotoAction:(id)sender;

@end
