//
//  RARideUpgrade.h
//  RideDriver
//
//  Created by Roberto Abreu on 6/7/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface RARideUpgrade : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSString *categoryName;
@property (nonatomic, strong) NSArray  *upgradeTargets;

@end
