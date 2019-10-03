//
//  SurgeAreaViewModel.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 11/8/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "SurgeAreaViewModel.h"

#import "DriverManager.h"
#import "RASessionManager.h"
#import "SurgeAreaCar.h"
#import "Util.h"

@implementation SurgeAreaViewModel

- (instancetype)initWithSurgeArea:(SurgeArea *)surgeArea {
    if (self = [self init]) {
        self.surgeAreaModel = surgeArea;
    }
    return self;
}

- (BOOL)canDraw {
    return [[DriverManager shared] isDriverOnActiveRide] == NO && self.surgeAreaModel.hasSurgeGeometry;
}

- (void)createSurgeAreaOnMap:(GMSMapView*)mapView {
    NSArray<NSString *> *userCarTypes = [RASessionManager shared].currentSession.userCarTypes;
    SurgeAreaCar *carToDraw = nil;
    if (self.canDraw && (carToDraw = [self surgeCarForCategories:userCarTypes])) {
        [self drawSurgeArea:self.surgeAreaModel forHighestCarType:carToDraw onMap:mapView];
        [self addTitleGroundOverlayForSurgeArea:self.surgeAreaModel andHighestCarType:carToDraw onMap:mapView];
    } else {
        [self clear];
    }
}
/**
 *  @return nil if no surge for categories
 */
- (SurgeAreaCar *)surgeCarForCategories:(NSArray<NSString *> *)categories {
    SurgeAreaCar *highestCar = nil;
    for (NSString *category in categories) {
        NSNumber *factor = self.surgeAreaModel.carCategoriesFactors[category];
        SurgeAreaCar *tempCar = [SurgeAreaCar carWithCategory:category andFactor:factor];
        if ([tempCar hasSurgeGreaterThanCar:highestCar]) {
            highestCar = tempCar;
        }
    }
    return highestCar;
}

- (void)drawSurgeArea:(SurgeArea *)surgeArea forHighestCarType:(SurgeAreaCar *)surgeCarType onMap:(GMSMapView*)mapView {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.polygon) {
            self.polygon = [[GMSPolygon alloc] init];
        }
        
        UIColor *color = [self colorForSurgeFactor:surgeCarType.factor.floatValue];
        self.polygon.fillColor   = color;
        self.polygon.strokeColor = color;
        self.polygon.strokeWidth = 2;
        self.polygon.path = surgeArea.boundary;
        self.polygon.map = mapView;
    });
}

- (void)addTitleGroundOverlayForSurgeArea:(SurgeArea*)surgeArea andHighestCarType:(SurgeAreaCar *)surgeCarType onMap:(GMSMapView *)mapView{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *titleImage = [self titleImageForSurgeFactor:surgeCarType.factor];
        if (self.factorText) {
            self.factorText.icon = titleImage;
            self.factorText.map = mapView;
        } else {
            GMSMarker *textMarker = [GMSMarker markerWithPosition:surgeArea.centerPoint];
            textMarker.appearAnimation = kGMSMarkerAnimationPop;
            textMarker.groundAnchor = CGPointMake(.5, .5);
            textMarker.icon         = titleImage;
            textMarker.opacity = 1.0;
            textMarker.map = mapView;
            self.factorText = textMarker;
        }
    });
}

- (void)clear {
    self.polygon.map = nil;
    self.factorText.map = nil;
    self.polygon = nil;
    self.factorText = nil;
}

- (id)copyWithZone:(NSZone *)zone {
    SurgeAreaViewModel *copy = [SurgeAreaViewModel new];
    if (copy) {
        copy.polygon = self.polygon.copy;
        copy.factorText = self.factorText.copy;
        copy.surgeAreaModel = self.surgeAreaModel.copy;
    }
    return copy;
}

#pragma mark - Helper

- (void)showSurgeAreaOnMap:(GMSMapView *)mapView {
    self.polygon.map = mapView;
    self.factorText.map = mapView;
}

- (UIColor *)colorForSurgeFactor:(CGFloat)sf {
    double alpha = 0.0;
    
    if (1.0 < sf && sf <= 1.25){
        alpha = 0.20;
    } else if (1.25 < sf && sf <= 1.50){
        alpha = 0.35;
    } else if (1.5 < sf && sf <= 2.0){
        alpha = 0.55;
    } else if (2.0 < sf){
        alpha = 0.65;
    }
    
    return [UIColor colorWithRed:29.0/255.0 green:169.0/255.0 blue:247.0/255.0 alpha:alpha];
}

- (UIImage *)titleImageForSurgeFactor:(NSNumber *)surgeFactor {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    formatter.roundingIncrement = [NSNumber numberWithDouble:0.01];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    NSString * surgeString = [NSString stringWithFormat:@"%@X",[formatter stringFromNumber:surgeFactor]];
    
    NSDictionary *attributes = @{NSFontAttributeName            : [UIFont fontWithName:@"Montserrat-Regular" size:14],
                                 NSForegroundColorAttributeName : [UIColor whiteColor],
                                 NSBackgroundColorAttributeName : [UIColor clearColor]};
    
    return [Util imageFromString:surgeString attributes:attributes size:CGSizeMake(50, 50)];
}

@end
