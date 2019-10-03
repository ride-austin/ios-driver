//
//  RAGroundOverlayManager.m
//  RideDriver
//
//  Created by Roberto Abreu on 9/13/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RAGroundOverlayManager.h"

#import "GoogleMapsManager.h"
#import "UIColor+HexUtils.h"

@implementation RAGroundOverlayManager

+ (void)minPoint:(CGPoint*)minPoint maxPoint:(CGPoint*)maxPoint fromLocations:(NSArray<CLLocation *> *)locations withMapView:(GMSMapView*)mapView {
    CGFloat minLat = CGFLOAT_MAX;
    CGFloat minLng = CGFLOAT_MAX;
    CGFloat maxLat = 0;
    CGFloat maxLng = 0;
    for (CLLocation *location in locations) {
        CGPoint mapPoint = [mapView.projection pointForCoordinate:location.coordinate];
        if (mapPoint.x < minLat) {
            minLat = mapPoint.x;
        }
        
        if (mapPoint.x > maxLat) {
            maxLat = mapPoint.x;
        }
        
        if (mapPoint.y < minLng) {
            minLng = mapPoint.y;
        }
        
        if (mapPoint.y > maxLng) {
            maxLng = mapPoint.y;
        }
    }
    *minPoint = CGPointMake(minLat, minLng);
    *maxPoint = CGPointMake(maxLat, maxLng);
}

+ (UIBezierPath *)pathForLocations:(NSArray<CLLocation *> *)locations minPoint:(CGPoint)minPoint maxPoint:(CGPoint)maxPoint shapeSize:(CGSize)shapeSize withMapView:(GMSMapView*)mapView {
    __block UIBezierPath *path = [UIBezierPath bezierPath];
    [locations enumerateObjectsUsingBlock:^(CLLocation * _Nonnull location, NSUInteger idx, BOOL * _Nonnull stop) {
        CGPoint mapPoint = [mapView.projection pointForCoordinate:location.coordinate];
        double x = (((mapPoint.x - minPoint.x) * (shapeSize.width)) / (maxPoint.x - minPoint.x));
        double y = (((mapPoint.y - minPoint.y) * (shapeSize.height)) / (maxPoint.y - minPoint.y));
        
        CGPoint point = CGPointMake(x, y);
        
        if (idx == 0) {
            [path moveToPoint:point];
        } else {
            [path addLineToPoint:point];
        }
    }];
    [path closePath];
    return path;
}

+ (void)groundOverlayForLocations:(NSArray<CLLocation *> *)locations mapView:(GMSMapView*)mapView completion:(GroundOverlayBlock)completion {
    //Get the Min and Max point
    CGPoint minPoint = CGPointZero;
    CGPoint maxPoint = CGPointZero;
    [self minPoint:&minPoint maxPoint:&maxPoint fromLocations:locations withMapView:mapView];
    
    //Set ContextSize
    CGSize contextSize = CGSizeMake(maxPoint.x - minPoint.x, maxPoint.y - minPoint.y);
    
    //Create Path
    UIBezierPath *path = [self pathForLocations:locations minPoint:minPoint maxPoint:maxPoint shapeSize:contextSize withMapView:mapView];
    
    //Create Overlay Image
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        UIGraphicsBeginImageContextWithOptions(contextSize, NO, [UIScreen mainScreen].scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        [[UIColor colorWithPatternImage:[UIImage imageNamed:@"waiting-pattern-bg"]] setFill];
        [[UIColor colorWithHex:@"#979797"] setStroke];

        //Clip Shape
        CGContextAddPath(context, path.CGPath);
        CGContextClip(context);
        
        //Draw Line Pattern
        CGFloat lineThickness = 2;
        CGFloat lineSpacing = 15;
        
        CGFloat position = -(contextSize.width > contextSize.height ? contextSize.width : contextSize.height) - lineThickness;
        while (position <= contextSize.width) {
            CGContextMoveToPoint(context, position - lineThickness, -lineThickness);
            CGContextAddLineToPoint(context, position + lineThickness + contextSize.height, lineThickness + contextSize.height);
            CGContextStrokePath(context);
            position += lineSpacing + lineThickness * 2;
        }
        
        //Draw Shape border
        [path setLineWidth:lineThickness];
        [path stroke];
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(image);
        });
    });
}

@end
