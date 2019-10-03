//
//  RARiderDataModel.h
//  RideDriver
//
//  Created by Roberto Abreu on 6/15/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RABaseDataModel.h"

@interface RARiderDataModel : RABaseDataModel

@property (nonatomic) NSString *firstName;
@property (nonatomic) NSString *lastName;
@property (nonatomic) NSString *fullName;
@property (nonatomic) NSString *phoneNumber;
@property (nonatomic) NSURL *photoURL;
@property (nonatomic) NSNumber *rating;

@end
