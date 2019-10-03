//
//  RATerm.h
//  RideDriver
//
//  Created by Roberto Abreu on 5/25/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RABaseDataModel.h"

@interface RATerm : RABaseDataModel

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSString *version;
@property (nonatomic, strong) NSDate *publication;

@end
