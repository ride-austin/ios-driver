//
//  RASideMenuHeaderView.h
//  Ride
//
//  Created by Theodore Gonzalez on 8/27/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RACustomView.h"

@interface RASideMenuHeaderView : RACustomView

+ (instancetype)viewWithWidth:(CGFloat)width target:(id)target action:(SEL)action;
- (void)updateName:(NSString *)name imageURL:(NSURL *)imageURL;

@end
