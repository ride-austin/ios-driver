//
//  RASupportTopic.h
//  RideDriver
//
//  Created by Robert on 10/3/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RABaseDataModel.h"

@interface RASupportTopic : RABaseDataModel

@property (nonatomic, readonly) NSString *topicDescription;
@property (nonatomic, readonly) BOOL hasChildren;
@property (nonatomic, readonly) BOOL hasForms;

@end
