//
//  CarPhotoUpdateCell.h
//  RideDriver
//
//  Created by Abdul Rehman on 08/11/2016.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CarPhotoUpdate.h"

@interface CarPhotoUpdateCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imgCar;
@property (weak, nonatomic) IBOutlet UIButton *btnUpdate;
@property (weak, nonatomic) IBOutlet UIImageView *imgPlaceHolder;

@end
