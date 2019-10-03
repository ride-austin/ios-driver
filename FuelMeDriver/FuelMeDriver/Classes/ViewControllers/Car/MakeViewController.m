//
//  RDMakeViewController.m
//  RideDriver
//
//  Created by Adriano Alencar on 19/05/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "MakeViewController.h"
#import "ModelViewController.h"
#import "Automobile.h"

@implementation MakeViewController

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.year;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];    
    NSDictionary *dictionary = [self.data objectAtIndex:indexPath.row];
    NSString *make = [dictionary objectForKey:@"make"];
    cell.textLabel.text = make;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dictionary = [self.data objectAtIndex:indexPath.row];
    NSString *make = [dictionary objectForKey:@"make"];
    [self performSegueWithIdentifier:@"ModelSegue" sender:make];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ModelViewController *modelController = [segue destinationViewController];
    modelController.year = self.year;
    modelController.make = sender;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Make";
    
    NSManagedObjectContext *moc = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
    NSFetchRequest *fetchRequest = [Automobile fetchRequest];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Automobile" inManagedObjectContext:moc];
    NSDictionary *entityProperties = [entity propertiesByName];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:[entityProperties objectForKey:@"make"]]];
    
    fetchRequest.returnsDistinctResults = YES;
    fetchRequest.resultType = NSDictionaryResultType;
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"make" ascending:YES];
    [fetchRequest setSortDescriptors:@[ sortDescriptor ]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"year", self.year];
    [fetchRequest setPredicate:predicate];
    
    self.data = [moc executeFetchRequest:fetchRequest error:nil];
}

@end

