//
//  ConfigDirectConnect.h
//  RideDriver
//
//  Created by Roberto Abreu on 11/13/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Mantle/Mantle.h>

@interface ConfigDirectConnect : MTLModel <MTLJSONSerializing>

@property (nonatomic) BOOL isEnabled;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *directConnectDescription;
@property (nonatomic) BOOL requiresChauffeur;

@end
