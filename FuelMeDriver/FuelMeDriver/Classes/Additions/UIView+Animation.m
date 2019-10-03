//
//  UIView+Animation.m
//  RideAustin.com
//
//  Created by Tyson Bunch on 10/3/12.
//  Copyright (c) 2012 FuelMe, Inc. All rights reserved.
//

#import "UIView+Animation.h"

@implementation UIView (Animation)

-(void) showAnimated:(CompletionBlock)completion {
    if(self.alpha<1.0) {
        [UIView animateWithDuration:0.75
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.alpha=1.0;
                     }
                     completion:completion];
    } else {
        if(completion) {
            completion(YES);
        }
    }
}

-(void) hideAnimated:(CompletionBlock)completion {
    if(self.alpha>0) {
    [UIView  animateWithDuration:0.75
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.alpha=0.0;
                     }
                     completion:completion];
    } else {
        if(completion) {
            completion(YES);
        }
    }
}


-(void) slide:(CGFloat)y completion:(CompletionBlock)completion {
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGRect f = self.frame;
                         self.frame = CGRectMake(f.origin.x, y, f.size.width, f.size.height);
                     }
                     completion:completion];
}
@end
