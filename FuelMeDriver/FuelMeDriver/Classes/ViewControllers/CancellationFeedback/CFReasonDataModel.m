//
//  CFReasonDataModel.m
//  Ride
//
//  Created by Theodore Gonzalez on 3/24/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import "CFReasonDataModel.h"

@implementation CFReasonDataModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return
    @{
      @"code" : @"code",
      @"reasonDescription" : @"description"
      };
}

@end
