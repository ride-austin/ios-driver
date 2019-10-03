//
//  MakeViewController.h
//  RideAustin.com
//
//  Created by Tyson Bunch on 12/17/12.
//  Copyright (c) 2012 FuelMe, Inc. All rights reserved.
//

#import "BaseViewController.h"

@interface MakeViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, retain) NSArray* makesData;
@property(nonatomic, retain) IBOutlet UITableView* makeTable;

- (id)initWithYear:(NSString*)year;

@end
