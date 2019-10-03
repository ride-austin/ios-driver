//
//  YearViewController.m
//  RideAustin.com
//
//  Created by Tyson Bunch on 12/17/12.
//  Copyright (c) 2012 FuelMe, Inc. All rights reserved.
//

#import "YearViewController.h"

#import "ConfigRegistration.h"
#import "DriverInspectionStickerViewController.h"
#import "MakeViewController.h"
#import "RACarManager.h"
#import "NSString+Utils.h"

@interface YearViewController ()

@end

@implementation YearViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [@"Year" localized];
    [self loadYearsData];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:[@"CANCEL" localized] style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    [self.navigationItem setRightBarButtonItem:doneButton];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.yearsData count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellId = @"YearViewCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [cell.textLabel setFont:[UIFont fontWithName:@"MuseoSlab-500" size:cell.textLabel.font.pointSize]];
        [cell.detailTextLabel setFont:[UIFont fontWithName:@"Museo-300" size:cell.detailTextLabel.font.pointSize]];
    }
    NSString *year =  [self.yearsData objectAtIndex:indexPath.row];
    cell.textLabel.text = year;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    NSString *year =  [self.yearsData objectAtIndex:indexPath.row];
    
    RACityDetail *cityDetail = (RACityDetail*)[self.userData objectForKey:@"cityDetail"];
    RAInspectionStickerDetail *inspectionSticker = cityDetail.inspectionSticker;
    
    if (inspectionSticker && ([year intValue] <= inspectionSticker.minYearRequired.intValue) && inspectionSticker.isEnabled) {
        
        ConfigRegistration *configRegistration = [ConfigRegistration configWithCity:[ConfigurationManager getRegisteredCity] andDetail:cityDetail];
        
        DriverInspectionStickerViewController *driverInspectionStickerViewController = [[DriverInspectionStickerViewController alloc] initWithYear:year userData:self.userData andRegConfig:configRegistration];
        
        [self.navigationController pushViewController:driverInspectionStickerViewController animated:YES];
    } else {
        [self.navigationController pushViewController:[[MakeViewController alloc] initWithYear:year]  animated:YES];
    }

}

- (void)loadYearsData {
    self.yearsData = [[RACarManager shared] getYearsWithOrder:NO andMinYear:self.minYear];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.yearTable reloadData];
    });
}

- (void)cancel {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
