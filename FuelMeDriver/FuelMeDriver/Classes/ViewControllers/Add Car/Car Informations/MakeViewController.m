//
//  MakeViewController.m
//  RideAustin.com
//
//  Created by Tyson Bunch on 12/17/12.
//  Copyright (c) 2012 FuelMe, Inc. All rights reserved.
//

#import "MakeViewController.h"

#import "LocationViewController.h"
#import "ModelViewController.h"
#import "NSString+Utils.h"
#import "RACarManager.h"

@interface MakeViewController ()

@property (nonatomic, strong) NSString* year;

@end

@implementation MakeViewController

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.year;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.makesData count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellId = @"MakeViewCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [cell.textLabel setFont:[UIFont fontWithName:@"MuseoSlab-500" size:cell.textLabel.font.pointSize]];
        [cell.detailTextLabel setFont:[UIFont fontWithName:@"Museo-300" size:cell.detailTextLabel.font.pointSize]];
    }
    
    NSString *make = [self.makesData objectAtIndex:indexPath.row];
    cell.textLabel.text = make;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *make = [self.makesData objectAtIndex:indexPath.row];
   
    [self.navigationController pushViewController:[[ModelViewController alloc] initWithYear:self.year make:make] animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [@"Make" localized];

    [self loadMakesData];
}

- (void)loadMakesData {
    
    self.makesData = [[RACarManager shared] getMakesWithOrder:YES andYear:self.year];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.makeTable reloadData];
    });
}

- (id)initWithYear:(NSString*)year {
    self = [super init];
    if(self) {
        self.year = year;
    }
    return self;
}

@end

