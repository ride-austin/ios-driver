//
//  RAAlertItem.h
//  Ride
//
//  Created by Roberto Abreu on 15/11/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RAAlertItem <NSObject>

- (NSString*)messageAlert;
- (NSInteger)statusCodeAlert;

@end

@interface NSString (RAAlertItem) <RAAlertItem>

@end

@implementation NSString (RAAlertItem)

- (NSString*)messageAlert {
    return self;
}

- (NSInteger)statusCodeAlert{
    return -1;
}

@end

@interface NSError (RAAlertItem) <RAAlertItem>

@end

@implementation NSError (RAAlertItem)

- (NSString*)messageAlert {
    
    NSString *message = self.localizedRecoverySuggestion;
    if (!message) {
        message = self.localizedFailureReason;
    }
    
    if (!message) {
        message = self.localizedDescription;
    }
    
    if (!message) {
        message = [NSString stringWithFormat:@"Unknown error. Status: %ld",(long)self.code];
    }
    
    return message;
}

- (NSInteger)statusCodeAlert{
    return self.code;
}

@end

