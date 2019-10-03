//
//  RDModelViewController.m
//  RideDriver
//
//  Created by Adriano Alencar on 19/05/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "ModelViewController.h"
#import "ColorViewController.h"

#define modelsURI (@"/api/vehicle/modelrepository/findmodelsbymakeandyear")

@implementation ModelViewController

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"%@ %@", self.year, self.make];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];    
    NSDictionary *dict = [self.data objectAtIndex:indexPath.row];
    NSString *model = [dict objectForKey:@"model"];
    cell.textLabel.text = model;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dict = [self.data objectAtIndex:indexPath.row];
    NSString *model = [dict objectForKey:@"model"];
    [self performSegueWithIdentifier:@"ColorSegue" sender:model];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ColorViewController *colorController = [segue destinationViewController];
    colorController.year = self.year;
    colorController.make = self.make;
    colorController.model = sender;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Model";
    
    NSManagedObjectContext *moc = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
    NSFetchRequest *fetchRequest = [Automobile fetchRequest];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Automobile" inManagedObjectContext:moc];
    NSDictionary *entityProperties = [entity propertiesByName];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:[entityProperties objectForKey:@"model"]]];
    
    fetchRequest.returnsDistinctResults = YES;
    fetchRequest.resultType = NSDictionaryResultType;
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"model" ascending:YES];
    [fetchRequest setSortDescriptors:@[ sortDescriptor ]];
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@ AND %K == %@", @"year", self.year, @"make", self.make];
    [fetchRequest setPredicate:predicate];
    
    self.data = [moc executeFetchRequest:fetchRequest error:nil];
}

@end