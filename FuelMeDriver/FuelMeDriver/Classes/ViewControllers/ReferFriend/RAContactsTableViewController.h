//
//  RAContactsTableViewController.h
//  RideDriver
//
//  Created by Kitos on 5/11/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, RAContactItemType){
    RATypeAll = 0,
    RATypePhone,
    RATypeEmail
};

@protocol RAContactsTableViewControllerDelegate <NSObject>

- (void)contactItemHasBeenselected:(NSString*)item itemType:(RAContactItemType)type;

@end

@interface RAContactsTableViewController : UITableViewController

@property (nonatomic) RAContactItemType filter;
@property (nonatomic, assign) id<RAContactsTableViewControllerDelegate> delegate;

@end
