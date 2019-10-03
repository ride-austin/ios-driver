//
//  RAContact.h
//  RideDriver
//
//  Created by Kitos on 5/11/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RALabeledValue : NSObject 

@property (nonatomic, strong) NSString *label;
@property (nonatomic, strong) NSString *value;

@end

@interface RAContact : NSObject

@property (nonatomic, strong) NSString *firstname;
@property (nonatomic, strong) NSString *lastname;
@property (nonatomic, strong) NSArray<RALabeledValue*> *phones;
@property (nonatomic, strong) NSArray<RALabeledValue*> *emails;

@end
