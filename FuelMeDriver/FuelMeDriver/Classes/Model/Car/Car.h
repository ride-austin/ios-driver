//
//  Car.h
//  RideAustin
//
//  Created by Tyson Bunch on 7/23/13.
//  Copyright (c) 2013 FuelMe, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RABaseDataModel.h"

@interface Car : RABaseDataModel

@property (nonatomic, retain) NSString *color;
@property (nonatomic, retain) NSString *inspectionStatus;
@property (nonatomic, retain) NSString *inspectionNotes;
//@property (nonatomic, readonly) NSString *inspectionSticker;
@property (nonatomic, retain) NSString *license;
@property (nonatomic, retain) NSString *make;
@property (nonatomic, retain) NSString *model;
@property (nonatomic, retain) NSString *year;
@property (nonatomic, retain) NSURL *photoUrl;
@property (nonatomic, strong) NSArray<NSString *>*carCategories;
/**
 *  @brief if isRemoved == YES, car is removed from console
 */
@property (nonatomic, readonly) BOOL isRemoved;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, strong) NSDate *insuranceExpiryDate;
@property (nonatomic, strong) NSURL *insurancePictureUrl;

- (NSString *)carName;

@end
