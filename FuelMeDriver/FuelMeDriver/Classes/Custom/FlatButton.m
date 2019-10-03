
//
//  FlatButton.m
//  FuelMe
//
//  Created by Tyson Bunch on 9/19/12.
//  Copyright (c) 2012 FuelMe, Inc. All rights reserved.
//

#import "FlatButton.h"

#import "UIColor+LightAndDark.h"

@implementation FlatButton

- (void)awakeFromNib {
    [super awakeFromNib];
    self.color = self.backgroundColor;
}

- (void)setColor:(UIColor *)color {
    _color = color;
    self.backgroundColor = color;
}

- (UIColor *)darkerColor {
    return [self.color darkerColor];
}

- (id)initWithFrame:(CGRect)frame color:(UIColor *)color {
    self = [super initWithFrame:frame];
    if (self) {
        self.color = color;
    }
    return self;
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    CGFloat alpha = enabled ? 1.0:0.25;
    CGFloat duration = enabled ? 0.25:0;
    [UIView animateWithDuration:duration animations:^{
        self.alpha = alpha;
    }];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    self.backgroundColor = highlighted ? self.highlightColor : self.color;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.backgroundColor = selected ? self.selectedColor : self.color;
}

@end
