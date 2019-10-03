//
//  ColorViewController.h
//  RideAustin.com
//
//  Created by Tyson Bunch on 12/17/12.
//  Copyright (c) 2012 FuelMe, Inc. All rights reserved.
//

#import "BaseViewController.h"

@interface ColorViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property(nonatomic, retain) IBOutlet NSArray* data;
@property(nonatomic, retain) IBOutlet UITableView* colorTable;

-(id)initWithYear:(NSString*)year make:(NSString*)make model:(NSString*)model;

@end
