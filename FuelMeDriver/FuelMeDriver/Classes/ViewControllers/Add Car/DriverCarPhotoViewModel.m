//
//  DriverCarPhotoViewModel.m
//  Ride
//
//  Created by Roberto Abreu on 16/11/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "DriverCarPhotoViewModel.h"

#import "DriverCarInformationViewController.h"
#import "DriverCarPhotoViewController.h"
#import "NSObject+className.h"
#import "NSString+Utils.h"

@implementation DriverCarPhotoViewModel

- (instancetype)initWithUserData:(NSMutableDictionary*)userData registrationConfig:(ConfigRegistration *)regConfig carPhotoType:(CarPhotoType)carPhotoType {
    if (self = [super init]) {
        self.userData = userData;
        self.carPhotoType = carPhotoType;
        _regConfig = regConfig;
    }
    return self;
}

- (NSString *)carPhotoDescription {
    switch (self.carPhotoType) {
        case FrontPhoto:
            return [@"Front left angle, showing the license plate" localized];
        case BackPhoto:
            return [@"Back right angle showing plate" localized];
        case InsidePhoto:
            return [@"Inside photo showing the entire back seat" localized];
        case TrunkPhoto:
            return [@"Open trunk, full view" localized];
    }
}

- (NSString *)carPhotoAlertDescription {
    switch (self.carPhotoType) {
        case FrontPhoto:
            return [@"Are you sure the Photo is clearly taken from the Front left angle side and shows your license plate?" localized];
        case BackPhoto:
            return [@"Are you sure the Photo is clearly taken from the Back right angle side and shows your license plate?" localized];
        case InsidePhoto:
            return [@"Are you sure the Photo is clearly taken from Inside the car showing the entire back seat?" localized];
        case TrunkPhoto:
            return [@"Are you sure the Photo is showing the Trunk open in full view?" localized];
    }
}

- (UIImage *)carPhotoDefaultImage {
    switch (self.carPhotoType) {
        case FrontPhoto:
            return [UIImage imageNamed:@"iconCarFrontLarge"];
        case BackPhoto:
            return [UIImage imageNamed:@"iconCarBackLarge"];
        case InsidePhoto:
            return [UIImage imageNamed:@"iconSeatsLarge"];
        case TrunkPhoto:
            return [UIImage imageNamed:@"iconCarTrunkLarge"];
    }
}

- (UIViewController *)routeController {
    switch (self.carPhotoType) {
        case FrontPhoto:
            return [[DriverCarPhotoViewController alloc] initWithUserData:self.userData registrationConfig:self.regConfig carPhotoType:BackPhoto];
        case BackPhoto:
            return [[DriverCarPhotoViewController alloc] initWithUserData:self.userData registrationConfig:self.regConfig carPhotoType:InsidePhoto];
        case InsidePhoto:
            return [[DriverCarPhotoViewController alloc] initWithUserData:self.userData registrationConfig:self.regConfig carPhotoType:TrunkPhoto];
        case TrunkPhoto:{
            DriverCarInformationViewController *driverCarInformationViewController = [[UIStoryboard storyboardWithName:@"DriverCarDetails" bundle:nil] instantiateViewControllerWithIdentifier:[DriverCarInformationViewController className]];
            driverCarInformationViewController.userData  = self.userData;
            driverCarInformationViewController.regConfig = self.regConfig;
            return driverCarInformationViewController;
        }
    }
}

@end
