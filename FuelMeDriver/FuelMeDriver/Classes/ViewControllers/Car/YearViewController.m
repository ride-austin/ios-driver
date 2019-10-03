//
//  RDYearViewController.m
//  RideDriver
//
//  Created by Adriano Alencar on 19/05/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "YearViewController.h"
#import "MakeViewController.h"

@interface YearViewController ()

@end

@implementation YearViewController


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    NSDictionary *dict = [self.data objectAtIndex:indexPath.row];
    cell.textLabel.text = [dict objectForKey:@"year"];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dict =  [self.data objectAtIndex:indexPath.row];
    NSString* year = [dict objectForKey:@"year"];
    [self performSegueWithIdentifier:@"MakeSegue" sender:year];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    MakeViewController *makeController = [segue destinationViewController];
    makeController.year = sender;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Year";
    
    NSManagedObjectContext *moc = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
    NSFetchRequest *fetchRequest = [Automobile fetchRequest];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Automobile" inManagedObjectContext:moc];
    NSDictionary *entityProperties = [entity propertiesByName];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:[entityProperties objectForKey:@"year"]]];
    
    fetchRequest.returnsDistinctResults = YES;
    fetchRequest.resultType = NSDictionaryResultType;
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"year" ascending:NO];
    [fetchRequest setSortDescriptors:@[ sortDescriptor ]];
    
    self.data = [moc executeFetchRequest:fetchRequest error:nil];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"CANCEL" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    [self.navigationItem setRightBarButtonItem:doneButton];
}

-(void)cancel {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
