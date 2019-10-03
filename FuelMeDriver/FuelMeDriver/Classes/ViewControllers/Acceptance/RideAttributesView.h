//
//  RideAttributesView.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 4/2/18.
//  Copyright © 2018 FuelMe LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RARideDataModel;
@interface RideAttributesView : UIView

@property (weak, nonatomic) IBOutlet UILabel *lbCarCategory;
@property (weak, nonatomic) IBOutlet UILabel *lbSurgeFactor;

- (instancetype)initWithFrame:(CGRect)frame andRide:(RARideDataModel *)ride;
@end
