//
//  UIView+Animation.h
//  RideAustin.com
//
//  Created by Tyson Bunch on 10/3/12.
//  Copyright (c) 2012 FuelMe, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Animation)

typedef void (^CompletionBlock)(BOOL finished);

-(void) showAnimated:(CompletionBlock)completion;
-(void) hideAnimated:(CompletionBlock)completion;
-(void) slide:(CGFloat)y completion:(CompletionBlock)completion;

@end
