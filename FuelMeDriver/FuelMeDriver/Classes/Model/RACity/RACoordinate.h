//
//  RACoordinate.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 11/28/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface RACoordinate : MTLModel <MTLJSONSerializing>

- (CLLocation *)location;

@end

