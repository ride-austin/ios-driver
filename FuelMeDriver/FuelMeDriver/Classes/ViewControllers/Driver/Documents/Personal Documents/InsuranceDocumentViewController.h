//
//  InsuranceDocumentViewController.h
//  RideDriver
//
//  Created by Roberto Abreu on 11/11/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseDocumentViewController.h"

@interface InsuranceDocumentViewController : BaseDocumentViewController <UITextFieldDelegate>

@property (nonatomic, copy) Car *selectedCar;
@property (nonatomic) BOOL isNewCar;

@end
