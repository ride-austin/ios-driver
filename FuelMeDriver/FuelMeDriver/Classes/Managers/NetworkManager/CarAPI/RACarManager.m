//
//  RACarManager.m
//  Ride
//
//  Created by Carlos Alcala on 11/25/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RACarManager.h"

#import "ErrorReporter.h"

static RACarManager *_shared = nil;

@implementation RACarManager

+ (RACarManager *)shared {
    if (!_shared) {
        _shared = [RACarManager new];
        
        [RACarAPI getAllCarsWithCompletion:^(NSArray<RACarDataModel *> *cars, NSError *error){
            if (!error) {
                _shared.cars = cars;
            } else {
                [ErrorReporter recordError:error withDomainName:LoadCarsData];
            }
        }];
        
    }
    return _shared;
}

+ (NSArray *)cars {
    return [RACarManager shared].cars;
}

- (NSArray *)getYearsWithOrder:(BOOL)ASC andMinYear:(NSNumber *)minYear {
    
    NSArray *years = [[self.cars valueForKey:@"year"] valueForKeyPath:@"@distinctUnionOfObjects.self"];
    
    if (minYear) {
        years = [years filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.intValue >= %i",[minYear intValue]]];
    }
    
    return [years sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"self" ascending:ASC]]];
}

- (NSArray *)getMakesWithOrder:(BOOL)ASC andYear:(NSString *)year {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"year = %@", year];
    NSArray *carsYear = [self.cars filteredArrayUsingPredicate:predicate];
    
    NSArray *makes = [[carsYear valueForKey:@"make"] valueForKeyPath:@"@distinctUnionOfObjects.self"];
    
    return [makes sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"self" ascending:ASC]]];
}

- (NSArray *)getModelsWithOrder:(BOOL)ASC withMake:(NSString *)make andYear:(NSString *)year{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"year = %@ AND make = %@", year, make];
    NSArray *carsYear = [self.cars filteredArrayUsingPredicate:predicate];
    
    NSArray *models = [[carsYear valueForKey:@"model"] valueForKeyPath:@"@distinctUnionOfObjects.self"];
    
    return [models sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"self" ascending:ASC]]];
}

@end
