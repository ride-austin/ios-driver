//
//  ModelViewController.h
//  RideAustin.com
//
//  Created by Tyson Bunch on 12/17/12.
//  Copyright (c) 2012 FuelMe, Inc. All rights reserved.
//

#import "BaseViewController.h"

@interface ModelViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, retain) IBOutlet NSArray* modelsData;
@property(nonatomic, retain) IBOutlet UITableView* modelTable;

- (id)initWithYear:(NSString*)year make:(NSString*)make;

@end
