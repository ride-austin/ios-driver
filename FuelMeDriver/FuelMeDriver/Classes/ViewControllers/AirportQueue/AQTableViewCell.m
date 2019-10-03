//
//  AQTableViewCell.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 8/15/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "AQTableViewCell.h"

@interface AQTableViewCell()

@property (weak, nonatomic) IBOutlet UIView *vWhite;
@property (weak, nonatomic) IBOutlet UIView *vSeparatorRight;
@property (weak, nonatomic) IBOutlet UIView *vSeparatorLeft;
//
//  73 for small phones
//
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintVSeparatorLeftLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintVSeparatorRightTrailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintLBCountWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintIVIconWidth;

@end

@implementation AQTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self configureDefaults];
    [self configureColors];
    [self configureLayout];
}

- (void)configureDefaults {
    self.lbType.text = @"";
    self.lbCount.text = @"";
}

- (void)configureColors {
    UIColor *grayColor = [UIColor colorWithRed:0.89 green:0.89 blue:0.89 alpha:1.00];
    UIColor *gunMetalColor = [UIColor colorWithRed:0.03 green:0.05 blue:0.09 alpha:1.00];
    self.vWhite.layer.borderWidth = 1;
    self.vWhite.layer.borderColor = grayColor.CGColor;
    self.vSeparatorLeft.backgroundColor  = grayColor;
    self.vSeparatorRight.backgroundColor = grayColor;
    self.lbType.textColor  = gunMetalColor;
    self.lbCount.textColor = gunMetalColor;
}

- (void)configureLayout {
    if ([UIScreen mainScreen].bounds.size.width <= 320) {
        CGFloat width = 73;
        self.constraintIVIconWidth.constant             = width;
        self.constraintLBCountWidth.constant            = width;
        self.constraintVSeparatorLeftLeading.constant   = width;
        self.constraintVSeparatorRightTrailing.constant = width;
    }
}

@end
