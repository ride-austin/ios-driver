//
//  RAAlertAction.h
//  RAAlertManager
//
//  Created by Theodore Gonzalez on 3/5/17.
//  Copyright © 2017 Crossover. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef void(^AlertActionHandler)(UIAlertAction * _Nullable action);
@interface RAAlertAction : NSObject
+ (_Nonnull instancetype)actionWithTitle:(nullable NSString *)title style:(UIAlertActionStyle)style handler:(_Nullable AlertActionHandler)handler;

@property (nullable, nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) UIAlertActionStyle style;
@property (nonatomic, copy) _Nullable AlertActionHandler handler;
@end
