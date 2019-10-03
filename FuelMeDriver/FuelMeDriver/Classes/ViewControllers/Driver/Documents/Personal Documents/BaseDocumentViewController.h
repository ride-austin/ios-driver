//
//  BaseDocumentViewController.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 1/19/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "BaseViewController.h"
#import "ConfigRegistration.h"

@interface BaseDocumentViewController : BaseViewController

@property (nonatomic) ConfigRegistration *regConfig;

- (BOOL)isImageValid:(UIImage *)image;

@end
