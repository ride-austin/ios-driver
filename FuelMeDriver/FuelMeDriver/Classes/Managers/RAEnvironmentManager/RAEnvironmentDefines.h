//
//  RAEnvironment.h
//  Ride
//
//  Created by Theodore Gonzalez on 12/4/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

//FIX: RA-5442 - Redefined Numeration to follow segmented control buttons on splash
typedef NS_ENUM(NSInteger, RAEnvironment) {
    RAProdEnvironment = 0,
    RAQAEnvironment = 1,
    RACustomEnvironment = 2,
    RAStageEnvironment = 3,
    RAFeatureEnvironment = 4,
    RADevEnvironment = 5,
    RAEmptyEnvironment = 6
};
