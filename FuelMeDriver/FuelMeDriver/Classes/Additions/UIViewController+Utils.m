//
//  UIViewController+Utils.m
//  RideDriver
//
//  Created by Carlos Alcala on 7/23/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "UIViewController+Utils.h"

#import <objc/runtime.h>

#import "AssetCityManager.h"


@implementation UIViewController (Utils)
@dynamic isShowing;

- (BOOL)isVisible {
    return [self isViewLoaded] && self.view.window;
}

-(void)setIsShowing:(BOOL)value{
    NSNumber *valueLiteral = [NSNumber numberWithBool: value];
    objc_setAssociatedObject(self, @selector(isShowing),valueLiteral, OBJC_ASSOCIATION_ASSIGN);
}

-(BOOL)isShowing{
    NSNumber *valueLiteral = objc_getAssociatedObject(self, @selector(isShowing));
    return [valueLiteral boolValue];
}

#pragma mark - UINavigationItem Utils

- (void)setupNavigationTitleWithString:(NSString*)title {
    if (title) {
        self.navigationItem.titleView = nil;
        self.navigationItem.title = title;
    } else {
        self.navigationItem.title = nil;
        UIImage *image = [AssetCityManager logoImageCurrentCity];
        self.navigationItem.titleView = [[UIImageView alloc] initWithImage: image];
    }
}

/**
 Navigation Title with Subtitle
 @param Title - to show the title Label
 @param Subtitle - to show the subtitle Label
 @returns nothing
 */
- (void)setupNavigationTitleWithTitle:(NSString*)title andSubtitle:(NSString*)subtitle {
    self.navigationItem.title = nil;
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:
                           CGRectMake(0, 0, 200, 20)];
    titleLabel.accessibilityIdentifier = @"titleLabel";
    titleLabel.isAccessibilityElement = YES;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [titleLabel setFont:[UIFont fontWithName:@"Montserrat-Regular" size:18]];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.text = title;
    [titleView addSubview:titleLabel];
    
    UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:
                              CGRectMake(0, 20, 200, 20)];
    subtitleLabel.accessibilityIdentifier = @"subtitleLabel";
    subtitleLabel.isAccessibilityElement = YES;
    subtitleLabel.backgroundColor = [UIColor clearColor];
    subtitleLabel.textAlignment = NSTextAlignmentCenter;
    [subtitleLabel setFont:[UIFont fontWithName:@"Montserrat-Light" size:12]];
    subtitleLabel.textColor = [UIColor lightGrayColor];
    subtitleLabel.text = subtitle;
    [titleView addSubview:subtitleLabel];
    
    self.navigationItem.titleView = titleView;
}

@end
