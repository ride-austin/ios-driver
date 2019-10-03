//
//  AQTableViewCell.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 8/15/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AQTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lbCount;
@property (weak, nonatomic) IBOutlet UILabel *lbType;
@property (weak, nonatomic) IBOutlet UIImageView *ivIcon;

@end
