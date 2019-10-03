//
//  SurgeAreaManager.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 11/8/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "SurgeAreaManager.h"

#import "NetworkManager.h"

@interface SurgeAreaManager()

@property (nonatomic) NSMutableDictionary<NSNumber*, SurgeAreaViewModel*> *surgeViewModels;

@end

@implementation SurgeAreaManager

- (instancetype)init {
    if (self = [super init]) {
        self.surgeViewModels = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)setMapView:(GMSMapView *)mapView {
    _mapView = mapView;
    [self showCurrentSurgeAreas];
}

- (void)handleSurgeAreaForEvent:(id <RASurgeAreaEventProtocol>)event {
    if (event.surgeAreasUpdated && event.surgeAreasUpdated.count > 0) {
        for (SurgeArea *surgeArea in event.surgeAreasUpdated) {
            [self updateSurgeArea:surgeArea];
        }
    } else {
        [self getSurgeAreas];
    }
}

- (NSMutableArray<SurgeAreaViewModel *> *)surgeViewModelsCopy {
    return [[NSMutableArray alloc] initWithArray:self.surgeViewModels.allValues copyItems:YES];
}

- (void)getSurgeAreasWithCompletion:(void (^)(void))completion {
    [[NetworkManager sharedInstance] getSurgeAreas:^(NSArray<SurgeArea *> *areasArray, NSError *error) {
        if (!error) {
            [self manipulateZipCodesForGeometryFromContent:areasArray];
        }
        
        if (completion) {
            completion();
        }
    }];
}

- (void)getSurgeAreas {
    [self getSurgeAreasWithCompletion:nil];
}

- (void)manipulateZipCodesForGeometryFromContent:(NSArray<SurgeArea*>*)content{
    
    //Get remote surgeAreas
    NSMutableDictionary<NSNumber*,SurgeArea*> *remoteSurgeAreas = [[NSMutableDictionary alloc] init];
    for (SurgeArea *surge in content) {
        remoteSurgeAreas[surge.modelID] = surge;
    }
    
    //Get diff between local and remote surgeAreas
    NSMutableArray<NSNumber*> *localSurgeAreasId = [self.surgeViewModels.allKeys mutableCopy];
    [localSurgeAreasId removeObjectsInArray:remoteSurgeAreas.allKeys];

    //Clear local diff surgeViewModels
    for (NSNumber *surgeAreaId in localSurgeAreasId) {
        [self.surgeViewModels[surgeAreaId] clear];
        [self.surgeViewModels removeObjectForKey:surgeAreaId];
    }
    
    //Show and Update SurgeAreas
    for (SurgeArea *surgeArea in remoteSurgeAreas.allValues) {
        SurgeAreaViewModel *surgeAreaViewModel = self.surgeViewModels[surgeArea.modelID];
        
        if (!surgeAreaViewModel) {
            surgeAreaViewModel = [[SurgeAreaViewModel alloc] initWithSurgeArea:surgeArea];
            self.surgeViewModels[surgeArea.modelID] = surgeAreaViewModel;
        } else {
            surgeAreaViewModel.surgeAreaModel = surgeArea;
        }
        
        [self attempToDrawSurgeAreaViewModel:surgeAreaViewModel];
    }
    
}

- (void)updateSurgeArea:(SurgeArea *)surgeArea {
    SurgeAreaViewModel *surgeViewModel = self.surgeViewModels[surgeArea.modelID];
    if (!surgeViewModel) {
        surgeViewModel = [SurgeAreaViewModel new];
        self.surgeViewModels[surgeArea.modelID] = surgeViewModel;
    }
    
    surgeViewModel.surgeAreaModel = surgeArea;
    [self attempToDrawSurgeAreaViewModel:surgeViewModel];
}

- (void)showCurrentSurgeAreas {
    for (SurgeAreaViewModel *viewModel in self.surgeViewModels.allValues) {
        [self attempToDrawSurgeAreaViewModel:viewModel];
    }
    [self getSurgeAreas];
}

- (void)hideCurrentSurgeAreas {
    for (SurgeAreaViewModel *viewModel in self.surgeViewModels.allValues) {
        [viewModel clear];
    }
}

- (void)attempToDrawSurgeAreaViewModel:(SurgeAreaViewModel*)surgeAreaViewModel {
    if (surgeAreaViewModel.canDraw && self.mapView) {
        [surgeAreaViewModel createSurgeAreaOnMap:self.mapView];
    } else {
        [surgeAreaViewModel clear];
    }
}

@end
