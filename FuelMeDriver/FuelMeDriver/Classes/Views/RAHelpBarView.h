//
//  RAHelpBarView.h
//  Ride
//
//  Created by Theodore Gonzalez on 12/9/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RACustomView.h"

@protocol RAHelpBarViewDelegate <NSObject>
- (void)didTapHelpBar;
@end

@interface RAHelpBarView : RACustomView

@property (weak, nonatomic) IBOutlet id<RAHelpBarViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *ivLogo;

@end
