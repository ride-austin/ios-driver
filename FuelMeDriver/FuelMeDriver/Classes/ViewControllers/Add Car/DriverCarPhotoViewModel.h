//
//  DriverCarPhotoViewModel.h
//  Ride
//
//  Created by Roberto Abreu on 16/11/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ConfigRegistration.h"
#import "RideDriverEnums.h"

@interface DriverCarPhotoViewModel : NSObject

@property (nonatomic) CarPhotoType carPhotoType;
@property (nonatomic) NSMutableDictionary *userData;
@property (nonatomic, readonly) ConfigRegistration *regConfig;
@property (nonatomic, readonly) NSString *carPhotoDescription;
@property (nonatomic, readonly) NSString *carPhotoAlertDescription;
@property (nonatomic, readonly) UIImage *carPhotoDefaultImage;
@property (nonatomic, readonly) UIViewController *routeController;
- (instancetype)initWithUserData:(NSDictionary*)userData registrationConfig:(ConfigRegistration *)regConfig carPhotoType:(CarPhotoType)carPhotoType;

@end
