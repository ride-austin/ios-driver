//
//  RAInspectionStickerDetail.h
//  Ride
//
//  Created by Roberto Abreu on 9/12/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RABaseDataModel.h"

@interface RAInspectionStickerDetail : RABaseDataModel

@property (nonatomic) NSString *navBarTitle;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *content;
/**
 all cars below minYearRequired is required to provide their inspectionSticker
 */
@property (nonatomic) NSNumber *minYearRequired;
@property (nonatomic) BOOL isEnabled;

@end
