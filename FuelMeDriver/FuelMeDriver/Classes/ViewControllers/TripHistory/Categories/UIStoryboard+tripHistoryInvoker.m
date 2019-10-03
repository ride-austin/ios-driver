//
//  UIStoryboard+tripHistoryInvoker.m
//  Ride
//
//  Created by Theodore Gonzalez on 5/25/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "UIStoryboard+tripHistoryInvoker.h"

@implementation UIStoryboard (tripHistoryInvoker)

+ (UIViewController *)tripHistoryViewControllerWithId:(NSString *)identifier {
    return [[UIStoryboard storyboardWithName:@"SupportTopics" bundle:nil] instantiateViewControllerWithIdentifier:identifier];
}

@end
