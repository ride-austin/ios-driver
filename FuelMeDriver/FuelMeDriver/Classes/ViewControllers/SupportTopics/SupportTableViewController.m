//
//  SupportTableViewController.m
//  Ride
//
//  Created by Robert on 7/2/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "SupportTableViewController.h"

#import "NSString+Utils.h"
#import "SupportViewController.h"
#import "UIViewController+tripHistoryNavigation.h"

@interface SupportTableViewController ()

@end

@implementation SupportTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.parentTopic ? self.parentTopic.topicDescription : [@"Select an Issue" localized];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50;
}

- (UIUserInterfaceStyle)overrideUserInterfaceStyle {
    return UIUserInterfaceStyleLight;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.subTopics.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SupportTripCell" forIndexPath:indexPath];
    
    NSString *issue = self.subTopics[indexPath.row].topicDescription;
    cell.textLabel.text = issue;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RASupportTopic *supportTopic = self.subTopics[indexPath.row];
    [self showNextScreenForTopic:supportTopic withRideId:self.rideId];
}


@end
