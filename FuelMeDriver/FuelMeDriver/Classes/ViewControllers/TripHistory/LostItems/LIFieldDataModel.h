//
//  LIFieldDataModel.h
//  Ride
//
//  Created by Theodore Gonzalez on 5/18/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RABaseDataModel.h"

typedef NS_ENUM(NSUInteger, LIFieldType) {
    LIFieldTypeText,
    LIFieldTypeBool,
    LIFieldTypePhone
};

@interface LIFieldDataModel : RABaseDataModel

@property (nonatomic, readonly) NSString *variable;
@property (nonatomic, readonly) NSString *fieldTitle;
@property (nonatomic, readonly) NSString *fieldType;
@property (nonatomic, readonly) NSString *fieldPlaceholder;
@property (nonatomic, readonly) BOOL isMandatory;

@end
