//
//  ColorViewController.m
//  RideAustin.com
//
//  Created by Tyson Bunch on 12/17/12.
//  Copyright (c) 2012 FuelMe, Inc. All rights reserved.
//

#import "ColorViewController.h"

#import "CarsDetailViewController.h"
#import "LocationViewController.h"
#import "NSString+Utils.h"

@interface ColorViewController ()

@property (nonatomic, strong) NSString *year;
@property (nonatomic, strong) NSString *make;
@property (nonatomic, strong) NSString *model;

@end

@implementation ColorViewController

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"%@ %@ %@", self.year, self.make, self.model];    
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.data count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellId = @"ColorViewCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [cell.textLabel setFont:[UIFont fontWithName:@"MuseoSlab-500" size:cell.textLabel.font.pointSize]];
        [cell.detailTextLabel setFont:[UIFont fontWithName:@"Museo-300" size:cell.detailTextLabel.font.pointSize]];
    }
    cell.textLabel.text = [self.data objectAtIndex:indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *color = [self.data objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:[[CarsDetailViewController alloc] initWithYear:self.year
                                                                                            make:self.make
                                                                                           model:self.model
                                                                                           color:color
                                                                                           image:nil] animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [@"Color" localized];
    
    self.data = [NSArray arrayWithObjects:
                 @"Black",@"Blue",@"Brown",@"Gray", @"Green",@"Orange",@"Red",@"Silver",@"White",@"Yellow/Gold",
                 nil];
}

-(id)initWithYear:(NSString*)year make:(NSString*)make model:(NSString*)model {
    self = [super init];
    if (self) {
        self.year = year;
        self.make = make;
        self.model = model;
    }
    return self;
}

@end
