//
//  ModelViewController.m
//  RideAustin.com
//
//  Created by Tyson Bunch on 12/17/12.
//  Copyright (c) 2012 FuelMe, Inc. All rights reserved.
//

#import "ModelViewController.h"

#import "ColorViewController.h"
#import "LocationViewController.h"
#import "NSString+Utils.h"
#import "RACarManager.h"

#define modelsURI (@"/api/vehicle/modelrepository/findmodelsbymakeandyear")

@interface ModelViewController ()

@property (nonatomic, strong) NSString* make;
@property (nonatomic, strong) NSString* year;

@end

@implementation ModelViewController

- (id)initWithYear:(NSString*)year make:(NSString*)make {
    self = [super init];
    if (self) {
        self.year = year;
        self.make = make;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [@"Model" localized];
    [self loadModelData];
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"%@ %@", self.year, self.make];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.modelsData count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellId = @"ModelViewCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [cell.textLabel setFont:[UIFont fontWithName:@"MuseoSlab-500" size:cell.textLabel.font.pointSize]];
        [cell.detailTextLabel setFont:[UIFont fontWithName:@"Museo-300" size:cell.detailTextLabel.font.pointSize]];
    }
    
    NSString *model = [self.modelsData objectAtIndex:indexPath.row];
    cell.textLabel.text = model;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *model = [self.modelsData objectAtIndex:indexPath.row];
    
    [self.navigationController pushViewController:[[ColorViewController alloc] initWithYear:self.year make:self.make model:model] animated:YES];
}

- (void)loadModelData {
    
    self.modelsData = [[RACarManager shared] getModelsWithOrder:YES withMake:self.make andYear:self.year];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.modelTable reloadData];
    });
}

@end
