//
//  RatingViewController.h
//  RideDriver
//
//  Created by Roberto Abreu on 7/29/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RARideDataModel.h"

#import "HCSStarRatingView.h"

typedef void(^VoidBlock)(void);

@interface RatingViewController : UIViewController

@property (strong, nonatomic) RARideDataModel *rideDataModel;
@property (nonatomic, copy) VoidBlock completion;
@property (nonatomic, copy) VoidBlock submitTapped;

//IBOutlets
@property (weak, nonatomic) IBOutlet HCSStarRatingView *ratingView;
@property (weak, nonatomic) IBOutlet UILabel *lblDriverEarning;
@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;

//Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHeightContainer;

- (instancetype)initWithRideDataModel:(RARideDataModel*)rideDataModel completionBlock:(void(^)(void))completion;

@end
