//
//  LIOptionDataModel.h
//  Ride
//
//  Created by Theodore Gonzalez on 5/18/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RABaseDataModel.h"
#import "LIFieldDataModel.h"

@interface LIOptionDataModel : RABaseDataModel

@property (nonatomic, readonly) NSString *actionTitle;
@property (nonatomic, readonly) NSString *actionType;
@property (nonatomic, readonly) NSString *body;
@property (nonatomic, readonly) NSArray<LIFieldDataModel *> *fields;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *headerText;

@end

