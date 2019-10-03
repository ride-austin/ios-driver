//
//  ConfigDriverActions.h
//  RideDriver
//
//  Created by Abdul Rehman on 03/10/2018.
//  Copyright © 2018 FuelMe LLC. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface ConfigDriverActions : MTLModel <MTLJSONSerializing>

@property (nonatomic) NSNumber *autoArriveDistanceToPickup;
@property (nonatomic) NSNumber *autoEndDistanceToDestination;
@property (nonatomic) NSNumber *allowArriveDistanceToPickup;
@property (nonatomic) NSNumber *remindToArriveDistanceFromPickup;

@end
