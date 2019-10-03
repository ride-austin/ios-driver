//
//  RiedeTypeCell.h
//  RideDriver
//
//  Created by Abdul Rehman on 25/06/2016.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RideTypeCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgBackground;
@property (weak, nonatomic) IBOutlet UILabel *lblCarType;
@property (weak, nonatomic) IBOutlet UIImageView *imgSelected;
@property (weak, nonatomic) IBOutlet UIImageView *imgCar;

@end
