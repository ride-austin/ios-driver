//
//  RAAlertAction.m
//  RAAlertManager
//
//  Created by Theodore Gonzalez on 3/5/17.
//  Copyright © 2017 Crossover. All rights reserved.
//

#import "RAAlertAction.h"

@implementation RAAlertAction
+(instancetype)actionWithTitle:(NSString *)title style:(UIAlertActionStyle)style handler:(void (^)(UIAlertAction *))handler {
    return [[self alloc] initWithTitle:title style:style handler:handler];
}
-(instancetype)initWithTitle:(NSString *)title style:(UIAlertActionStyle)style handler:(void (^)(UIAlertAction *))handler {
    self = [super init];
    if (self) {
        _title   = title;
        _style   = style;
        _handler = handler;
    }
    return self;
}
@end
