//
//  RAAvatarDataModel.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 8/30/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RABaseDataModel.h"

@interface RAAvatarDataModel : RABaseDataModel
@property (nonatomic, readonly) NSString *type;
@property (nonatomic, readonly) BOOL active;
@end
