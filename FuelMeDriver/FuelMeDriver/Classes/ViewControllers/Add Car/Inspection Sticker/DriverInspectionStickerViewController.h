//
//  DriverInspectionStickerViewController.h
//  Ride
//
//  Created by Roberto Abreu on 9/12/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseDocumentViewController.h"
#import "Car.h"

@interface DriverInspectionStickerViewController : BaseDocumentViewController <UITextFieldDelegate>

@property (nonatomic) NSMutableDictionary *userData;
@property (nonatomic) NSString *yearSelected;
@property (nonatomic) Car* car; //Used to update Inspection Sticker of Car

- (instancetype)initWithYear:(NSString*)year userData:(NSMutableDictionary*)userData andRegConfig:(ConfigRegistration*)regConfig;

- (instancetype)initWithCar:(Car*)car andRegConfig:(ConfigRegistration*)regConfig;

@end
