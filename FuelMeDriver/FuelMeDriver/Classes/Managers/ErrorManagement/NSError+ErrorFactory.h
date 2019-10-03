//
//  NSError+ErrorFactory.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 7/17/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (ErrorFactory)

- (NSError *)filteredErrorAtReponse:(NSHTTPURLResponse *)response;

@end
