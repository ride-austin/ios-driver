//
//  DriverStatusButton.m
//  RideDriver
//
//  Created by Marcos Alba on 7/6/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "DriverStatusButton.h"

#import "DriverManager.h"
#import "UIColor+HexUtils.h"

#define ONLINE_COLOR [UIColor colorWithHex:@"01BC00"]
#define OFFLINE_COLOR [UIColor colorWithHex:@"FF1100"]
#define SYNC_COLOR [UIColor colorWithHex:@"F8C61C"]
static NSString *const kOnlineTitle = @"ONLINE";
static NSString *const kOfflineTitle = @"OFFLINE";
static NSString *const kSyncTitle    = @"OFFLINE";
static NSString *const kSyncingTitle = @"SYNCING";

@interface DriverStatusButton ()

@property (nonatomic, strong) UIActivityIndicatorView *spin;

@end

@implementation DriverStatusButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.titleLabel setFont:[UIFont fontWithName:@"Montserrat-Regular" size:13]];
        [self.layer setCornerRadius:frame.size.height/2.0];
        self.accessibilityIdentifier = @"driverStatusButton";
        
        self.spin = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        self.spin.hidesWhenStopped = YES;
        self.spin.center = CGPointMake(CGRectGetWidth(self.spin.frame)/2 + 4, CGRectGetMidY(frame));
        self.status = DABSOffline;
    }
    return self;
}


- (void)setStatus:(DriverStatusButtonState)status {
    _status = status;
    
    dispatch_async(dispatch_get_main_queue(), ^{        
        switch (status) {
            case DABSOffline:
                self.hidden = NO;
                self.enabled = YES;
                self.alpha = 1;
                [self setBackgroundColor:OFFLINE_COLOR];
                [self setTitle:kOfflineTitle forState:UIControlStateNormal];
                [self setTitleEdgeInsets:UIEdgeInsetsZero];
                [self.spin stopAnimating];
                [self.spin removeFromSuperview];
                
                break;
            case DABSOnline:
                self.hidden = NO;
                self.enabled = YES;
                self.alpha = 1;
                [self setBackgroundColor:ONLINE_COLOR];
                [self setTitle:kOnlineTitle forState:UIControlStateNormal];
                [self setTitleEdgeInsets:UIEdgeInsetsZero];
                [self.spin stopAnimating];
                [self.spin removeFromSuperview];
                
                break;
            case DABSSync:
                self.hidden = NO;
                self.enabled = YES;
                self.alpha = 1;
                #ifdef QA
                    [self setBackgroundColor:SYNC_COLOR];
                #else
                    [self setBackgroundColor:OFFLINE_COLOR];
                #endif
                [self setTitle:kSyncTitle forState:UIControlStateNormal];
                [self setTitleEdgeInsets:UIEdgeInsetsZero];
                [self.spin stopAnimating];
                [self.spin removeFromSuperview];

                break;
            case DABSLoading:
                self.hidden = NO;
                self.enabled = NO;
                self.alpha = 0.5;
                [self setBackgroundColor:SYNC_COLOR];
                [self setTitle:kSyncingTitle forState:UIControlStateNormal];
                [self setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
                [self.spin setHidden:NO];
                [self.spin startAnimating];
                [self addSubview:self.spin];
                
                break;
            case DABSDisabled:
                self.hidden = NO;
                self.enabled = NO;
                self.alpha = 0.5;

                break;

            case DABSHidden:
                self.hidden = YES;
                
                break;
                
            default:
                self.hidden = NO;
                self.enabled = YES;
                self.alpha = 1;
                [self setBackgroundColor:OFFLINE_COLOR];
                [self setTitle:kOfflineTitle forState:UIControlStateNormal];
                [self setTitleEdgeInsets:UIEdgeInsetsZero];
                [self.spin stopAnimating];
                [self.spin removeFromSuperview];
                break;
        }
    });

}

- (void)setStatusBasedOnAvailability {
    [self setStatus:[[DriverManager shared] isDriverOnline] ? DABSOnline : DABSOffline];
}

@end
