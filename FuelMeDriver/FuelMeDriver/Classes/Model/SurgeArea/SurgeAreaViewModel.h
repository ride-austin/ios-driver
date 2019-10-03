//
//  SurgeAreaViewModel.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 11/8/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "SurgeArea.h"

@interface SurgeAreaViewModel : NSObject <NSCopying>

@property (nonatomic) SurgeArea  *surgeAreaModel;
@property (nonatomic) GMSPolygon *polygon;
@property (nonatomic) GMSMarker *factorText;

- (instancetype)initWithSurgeArea:(SurgeArea*)surgeArea;
- (BOOL)canDraw;
- (void)createSurgeAreaOnMap:(GMSMapView*)mapView;
- (void)showSurgeAreaOnMap:(GMSMapView *)mapView;
- (void)clear;

@end
