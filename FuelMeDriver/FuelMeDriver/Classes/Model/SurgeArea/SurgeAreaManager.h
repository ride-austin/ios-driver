//
//  SurgeAreaManager.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 11/8/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "RAEventsProtocol.h"
#import "SurgeAreaViewModel.h"

@interface SurgeAreaManager : NSObject

@property (nonatomic,weak) GMSMapView *mapView;

-(void)handleSurgeAreaForEvent:(id <RASurgeAreaEventProtocol>)event;
- (NSMutableArray<SurgeAreaViewModel *> *)surgeViewModelsCopy;
- (void)getSurgeAreasWithCompletion:(void(^)(void))completion;

- (void)showCurrentSurgeAreas;
- (void)hideCurrentSurgeAreas;

@end
