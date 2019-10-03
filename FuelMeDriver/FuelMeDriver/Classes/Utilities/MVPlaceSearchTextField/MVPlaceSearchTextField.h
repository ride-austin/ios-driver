//
//  MVPlaceSearchTextField.h
//  PlaceSearchAPIDEMO
//
//  Created by Mrugrajsinh Vansadia on 26/04/14.
//  Copyright (c) 2014 Mrugrajsinh Vansadia. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MLPAutoCompleteTextField.h"
#import "MVPlaceSearchTextField.h"
#import "PlaceObject.h"

#import <GoogleMaps/GoogleMaps.h>

@import GooglePlaces;

@protocol PlaceSearchTextFieldDelegate;

@interface MVPlaceSearchTextField : MLPAutoCompleteTextField
@property(nonatomic,strong)NSString *strApiKey;
@property(nonatomic,weak)IBOutlet id<PlaceSearchTextFieldDelegate>placeSearchDelegate;
@property(nonatomic,strong)GMSMapView * mapview;

@end

@protocol PlaceSearchTextFieldDelegate <NSObject>

- (void)placeSearch:(MVPlaceSearchTextField*)textField ResponseForSelectedPlace:(GMSPlace*)responseDict;
- (void)placeSearchWillShowResult:(MVPlaceSearchTextField*)textField;
- (void)placeSearchWillHideResult:(MVPlaceSearchTextField*)textField;
- (void)placeSearch:(MVPlaceSearchTextField*)textField ResultCell:(UITableViewCell*)cell withPlaceObject:(PlaceObject*)placeObject atIndex:(NSInteger)index;
@end

