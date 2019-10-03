//
//  UIViewController+tripHistoryNavigation.m
//  Ride
//
//  Created by Theodore Gonzalez on 5/25/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "UIViewController+tripHistoryNavigation.h"

#import "LostItemFormViewController.h"
#import "NSObject+className.h"
#import "SupportTableViewController.h"
#import "SupportTopicAPI.h"
#import "SupportViewController.h"
#import "UIStoryboard+tripHistoryInvoker.h"
#import "RAAlertManager.h"
#import <SVProgressHUD/SVProgressHUD.h>

@implementation UIViewController (tripHistoryNavigation)

#pragma mark - Navigation

- (void)showNextScreenForTopic:(RASupportTopic *)supportTopic withRideId:(NSNumber *)rideId {
    if (supportTopic.hasChildren) {
        [self navigateToChildrenOfTopic:supportTopic withRideId:rideId];
    } else if (supportTopic.hasForms) {
        [self navigateToFormOfTopic:supportTopic withRideId:rideId];
    } else {
        [self showSupportViewControllerWithTopic:supportTopic andRideId:rideId];
    }
}

#pragma mark - Load Data

- (void)navigateToChildrenOfTopic:(RASupportTopic *)supportTopic withRideId:(NSNumber *)rideId {
    [SVProgressHUD show];
    [SupportTopicAPI getTopicsWithParentId:supportTopic.modelID withCompletion:^(NSArray<RASupportTopic *> *supportTopics, NSError *error) {
        [SVProgressHUD dismiss];
        if (error) {
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive]];
        } else {
            if (supportTopics.count > 0) {
                [self showSupportListWithTopics:supportTopics fromParent:supportTopic andRideId:rideId];
            } else {
                [self showSupportViewControllerWithTopic:supportTopic andRideId:rideId];
            }
        }
    }];
}

- (void)navigateToFormOfTopic:(RASupportTopic *)supportTopic withRideId:(NSNumber *)rideId {
    [SVProgressHUD show];
    [SupportTopicAPI getFormForTopic:supportTopic withCompletion:^(LIOptionDataModel *form, NSError *error) {
        [SVProgressHUD dismiss];
        if (error) {
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive]];
        } else {
            [self showFormViewControllerWithTopic:supportTopic form:form andRideId:rideId];
        }
    }];
}

#pragma mark - Show View Controllers
- (void)showFormViewControllerWithTopic:(RASupportTopic *)supportTopic
                                   form:(LIOptionDataModel *)form
                              andRideId:(NSNumber *)rideId {
    LostItemFormViewController *vc = (LostItemFormViewController *)[UIStoryboard tripHistoryViewControllerWithId:[LostItemFormViewController className]];
    [vc setFormDataModel:form andRideId:rideId];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showSupportListWithTopics:(NSArray *)supportTopics
                       fromParent:(RASupportTopic *)supportTopic
                        andRideId:(NSNumber *)rideId {
    SupportTableViewController *vc = (SupportTableViewController *)[UIStoryboard tripHistoryViewControllerWithId:[SupportTableViewController className]];
    vc.rideId = rideId;
    vc.parentTopic = supportTopic;
    vc.subTopics   = supportTopics;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showSupportViewControllerWithTopic:(RASupportTopic *)supportTopic
                                 andRideId:(NSNumber *)rideId {
    SupportViewController *vc = (SupportViewController *)[UIStoryboard tripHistoryViewControllerWithId:[SupportViewController className]];
    vc.selectedSupportTopic = supportTopic;
    vc.rideId = rideId;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
