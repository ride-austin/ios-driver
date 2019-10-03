//
//  UIBarButtonItem+RABarButton.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 3/9/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "UIBarButtonItem+RABarButton.h"
#import "UIColor+HexUtils.h"
@implementation UIBarButtonItem (RABarButton)
+ (UIBarButtonItem *)RABarButtonWithTitle:(NSString *)title
                                   target:(id)target
                                   action:(SEL)action {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat btnContactWidth = [UIScreen mainScreen].bounds.size.width <= 320 ? 68.0 : 80.0;
    btn.frame = CGRectMake(0, 0, btnContactWidth, 28.0);
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithHex:@"2C323C"] forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont fontWithName:@"Montserrat-Regular" size:12]];
    
    btn.layer.borderColor = [UIColor colorWithHex:@"#DFDFDF"].CGColor;
    btn.layer.borderWidth = 0.7;
    btn.layer.cornerRadius = 14.0;
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchDown];
    return [[UIBarButtonItem alloc] initWithCustomView:btn];
}
@end
