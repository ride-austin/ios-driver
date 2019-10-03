//
//  FlatButton+StyleFacade.m
//  RideDriver
//
//  Created by Roberto Abreu on 27/12/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "FlatButton+StyleFacade.h"

#import "AssetCityManager.h"
#import "UIColor+HexUtils.h"

@implementation FlatButton (StyleFacade)

- (void)applyLoginStyle {
    self.backgroundColor = [UIColor clearColor];
    self.tintColor       = [AssetCityManager colorCurrentCity:Foreground];
    self.highlightColor  = [AssetCityManager colorCurrentCity:Foreground];
    self.selectedColor   = [AssetCityManager colorCurrentCity:SecondaryBack];
    
    [self setTitleColor:[AssetCityManager colorCurrentCity:Foreground] forState:UIControlStateNormal];
    [self setTitleColor:[AssetCityManager colorCurrentCity:SecondaryText] forState:UIControlStateSelected];
    [self setTitleColor:[AssetCityManager colorCurrentCity:SecondaryText] forState:UIControlStateHighlighted];
    
    self.layer.masksToBounds = NO;
    self.layer.shadowRadius  = 5;
    self.layer.shadowOpacity = 0.5;
    self.layer.borderColor   = [AssetCityManager colorCurrentCity:Border].CGColor;
}

- (void)applyRegisterStyle {
    self.backgroundColor   = [AssetCityManager colorCurrentCity:Background];
    self.tintColor         = [AssetCityManager colorCurrentCity:Foreground];
    self.highlightColor    = [AssetCityManager colorCurrentCity:SecondaryText];
    self.selectedColor     = [AssetCityManager colorCurrentCity:SecondaryText];
    self.layer.borderColor = [AssetCityManager colorCurrentCity:Border].CGColor;
    self.color             = self.backgroundColor;
    
    [self setTitleColor:[AssetCityManager colorCurrentCity:Foreground] forState:UIControlStateNormal];
    [self setTitleColor:[AssetCityManager colorCurrentCity:SecondaryBack] forState:UIControlStateHighlighted];
    [self setTitleColor:[AssetCityManager colorCurrentCity:SecondaryText] forState:UIControlStateSelected];
}

#pragma mark - Trip button Style

- (void)applyDefaultTripButtonStyle {
    [self setTitle:@"" forState:UIControlStateNormal];
    [self applyBackgroundColor:[UIColor clearColor]];
}

- (void)applyArrivedStyle {
    [self setTitle:@"ARRIVED" forState:UIControlStateNormal];
    [self applyBackgroundColor:[UIColor colorWithHex:@"#1DA9F7"]];
}

- (void)applyBeginTripStyle {
    [self setTitle:@"BEGIN TRIP" forState:UIControlStateNormal];
    [self applyBackgroundColor:[UIColor colorWithHex:@"#1DA9F7"]];
}

- (void)applyEndTripStyle {
    [self setTitle:@"END TRIP" forState:UIControlStateNormal];
    [self applyBackgroundColor:[UIColor colorWithHex:@"#FF0000"]];
}

- (void)applyBackgroundColor:(UIColor*)color {
    self.color          = color;
    self.tintColor      = color;
    self.highlightColor = color;
    self.selectedColor  = color;
}

@end
