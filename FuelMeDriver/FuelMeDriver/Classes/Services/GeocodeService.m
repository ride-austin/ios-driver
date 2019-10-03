//
//  GeocodeService.m
//  RideDriver
//
//  Created by Roberto Abreu on 7/19/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "GeocodeService.h"

#import <AddressBookUI/AddressBookUI.h>

#import "ErrorReporter.h"

#import <GoogleMaps/GoogleMaps.h>

@interface GeocodeService ()

@property(nonatomic, strong) GMSGeocoder *googleGeoCoder;
@property(nonatomic, strong) CLGeocoder *clGeoCoder;

@end

@implementation GeocodeService

+ (instancetype)sharedInstance {
    static GeocodeService *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[GeocodeService alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.googleGeoCoder = [GMSGeocoder geocoder];
        self.clGeoCoder = [[CLGeocoder alloc] init];
    }
    return self;
}

- (void)reverseGeo:(CLLocation*)location completeBlock:(LocationServiceAddressBlock)completeBlock {
    [self.googleGeoCoder reverseGeocodeCoordinate:location.coordinate
                                completionHandler:^(GMSReverseGeocodeResponse *response, NSError *error) {
                                    if (!error) {
                                        GMSAddress *googleAddress = [response firstResult];
                                        if (googleAddress) {
                                            NSString *address = googleAddress.thoroughfare;
                                            NSString *zip = googleAddress.postalCode;
                                            if (!zip) {
                                                [self useAppleGeoCoderForLocation:location completeBlock:completeBlock];
                                            } else {
                                                NSString *fullAddress = nil;
                                                NSString *city = googleAddress.locality;
                                                NSString *state = googleAddress.administrativeArea;
                                                NSString *county = googleAddress.locality;
                                                NSString *neighborhood = googleAddress.subLocality;
                                                
                                                NSArray *lines = googleAddress.lines;
                                                if (lines) {
                                                    fullAddress = [lines componentsJoinedByString:@"\n"];
                                                }
                                                
                                                if (!fullAddress) {
                                                    fullAddress = googleAddress.locality;
                                                }
                                                
                                                if (completeBlock) {
                                                    completeBlock(zip, address, fullAddress, city, state, county, neighborhood, nil);
                                                } else {
                                                    DBLog(@"Error: GEO CODE NOT WORKING");
                                                }
                                            }
                                        } else {
                                            DBLog(@"Reverse Geo Code Google no address for location: %@", location);
                                            [self useAppleGeoCoderForLocation:location completeBlock:completeBlock];
                                        }
                                    } else {
                                        [ErrorReporter recordError:error withDomainName:GOOGLEReverseGeocode];
                                        DBLog(@"Reverse Geo Code Google no address for location: %@", location);
                                        [self useAppleGeoCoderForLocation:location completeBlock:completeBlock];
                                    }
                                }];
}

- (void)useAppleGeoCoderForLocation:(CLLocation*)location completeBlock:(LocationServiceAddressBlock)completeBlock {
    [self.clGeoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error) {
            if (placemarks && placemarks.count > 0) {
                CLPlacemark *placemark = [placemarks firstObject];
                
                NSString *address = placemark.thoroughfare;
                NSString *zip = placemark.postalCode;
                NSString *fullAddress = ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO);
                
                NSString *city = placemark.locality;
                NSString *state = placemark.administrativeArea;
                NSString *county = placemark.subAdministrativeArea;
                NSString *neighborhood = placemark.subLocality;
                
                if (!fullAddress) {
                    fullAddress = placemark.name;
                }
                
                if (!fullAddress) {
                    fullAddress = placemark.locality;
                }
                
                if (completeBlock) {
                    completeBlock(zip, address, fullAddress, city, state, county, neighborhood, nil);
                }
            } else {
                DBLog(@"Reverse Geo Code Apple no address for location: %@", location);
            }
        } else {
            DBLog(@"Reverse Geo Code Apple error: %@", [error localizedDescription]);
            if (completeBlock) {
                [ErrorReporter recordError:error withDomainName:APPLEReverseGeoCode];
                completeBlock(nil, nil, nil, nil, nil, nil, nil, error);
            }
        }
    }];
}

@end
