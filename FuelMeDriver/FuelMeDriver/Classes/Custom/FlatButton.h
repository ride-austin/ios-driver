//
//  GradientButton.h
//  FuelMe
//
//  Created by Tyson Bunch on 9/19/12.
//  Copyright (c) 2012 FuelMe, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlatButton : UIButton

//Properties
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) UIColor *highlightColor;
@property (nonatomic, strong) UIColor *selectedColor;

- (id)initWithFrame:(CGRect)frame color:(UIColor*)color;

- (UIColor *)darkerColor;

@end
