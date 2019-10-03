//
//  RDColorViewController.m
//  RideDriver
//
//  Created by Adriano Alencar on 19/05/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "ColorViewController.h"
#import "CarsDetailViewController.h"
#import "CZPhotoPickerController.h"


@interface ColorViewController ()

@property (nonatomic, strong) CZPhotoPickerController *photoPicker;

@end

@implementation ColorViewController

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"%@ %@ %@", self.year, self.make, self.model];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.text = [self.data objectAtIndex:indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *color = [self.data objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"CarDetailsSegue" sender:color];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    CarsDetailViewController *carDetailsController = [segue destinationViewController];
    [carDetailsController setDetails:self.year make:self.make model:self.model color:sender image:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Color";
    self.data = @[ @"Black",@"Blue",@"Brown",@"Gray", @"Green",@"Orange",@"Red",@"Silver",@"White",@"Yellow/Gold" ];
}

@end