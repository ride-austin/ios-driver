//
//  AbstractCarDetailViewController.h
//  RideDriver
//
//  Created by Adriano Alencar on 20/05/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "BaseViewController.h"

@interface AbstractCarDetailViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, retain) IBOutlet NSArray* data;
@property(nonatomic, retain) IBOutlet UITableView* yearTable;

@end
