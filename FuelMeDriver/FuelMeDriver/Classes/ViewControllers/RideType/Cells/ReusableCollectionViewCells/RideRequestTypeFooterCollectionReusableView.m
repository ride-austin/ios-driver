//
//  RideRequestTypeFooterCollectionReusableView.m
//  RideDriver
//
//  Created by Roberto Abreu on 10/30/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//
#import "RideRequestTypeFooterCollectionReusableView.h"
@interface RideRequestTypeFooterCollectionReusableView()
@property (weak, nonatomic) IBOutlet UIView *viewContainer;
@end

@implementation RideRequestTypeFooterCollectionReusableView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (void)setSegmentedControl:(UISegmentedControl *)segc {
    _segmentedControl = segc;
    if (_segmentedControl) {
        [self.viewContainer addSubview:segc];
        
        CGFloat xmargin = 14;
        CGFloat ymargin = 2;
        [NSLayoutConstraint activateConstraints:
         @[
           [segc.leadingAnchor constraintEqualToAnchor:self.viewContainer.leadingAnchor constant:xmargin],
           [self.viewContainer.trailingAnchor constraintEqualToAnchor:segc.trailingAnchor constant:xmargin],
           [segc.topAnchor constraintEqualToAnchor:self.viewContainer.topAnchor constant:ymargin],
           [self.viewContainer.bottomAnchor constraintEqualToAnchor:segc.bottomAnchor constant:ymargin]
           ]];
    }
}
@end
