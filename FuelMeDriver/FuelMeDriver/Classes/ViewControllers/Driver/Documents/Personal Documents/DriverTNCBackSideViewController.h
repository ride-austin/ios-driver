//
//  DriverTNCBackSideViewController.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 1/19/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "BaseDocumentViewController.h"

@protocol BackSideDelegate <NSObject>

- (void)backSideSaved:(UIImage *)backSideImage expirationDate:(NSDate*)expirationDate;

@end

@interface DriverTNCBackSideViewController : BaseDocumentViewController

@property (strong, nonatomic) NSDate *validityDate;
@property (weak, nonatomic) id<BackSideDelegate> delegate;

@end
