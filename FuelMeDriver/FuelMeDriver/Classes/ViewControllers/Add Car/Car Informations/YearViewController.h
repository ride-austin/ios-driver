//
//  YearViewController.h
//  RideAustin.com
//
//  Created by Tyson Bunch on 12/17/12.
//  Copyright (c) 2012 FuelMe, Inc. All rights reserved.
//

#import "BaseViewController.h"

@interface YearViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) IBOutlet NSArray* yearsData;
@property (nonatomic, retain) IBOutlet UITableView* yearTable;
@property (nonatomic, strong) NSMutableDictionary *userData;
@property (nonatomic, strong) NSNumber *minYear;

@end
