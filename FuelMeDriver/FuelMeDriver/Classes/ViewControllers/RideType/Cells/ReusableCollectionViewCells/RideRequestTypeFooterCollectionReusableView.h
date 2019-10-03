//
//  RideRequestTypeFooterCollectionReusableView.h
//  RideDriver
//
//  Created by Roberto Abreu on 10/30/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RideRequestTypeFooterCollectionReusableView : UICollectionReusableView


@property (strong, nonatomic) UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UILabel *lblCategoryDescription;

//Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHeightDriverTypeSwitch;

@end

