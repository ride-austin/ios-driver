//
//  DocumentsMenuViewController.m
//  RideDriver
//
//  Created by Abdul Rehman on 08/11/2016.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "DocumentsMenuViewController.h"

#import "DocumentsMenuTableViewCell.h"
#import "DriverTNCViewController.h"
#import "LicenseDocumentViewController.h"
#import "NSObject+className.h"
#import "NSString+Utils.h"
#import "RATableItem.h"

static NSString * const kDriversLicense = @"Driver's License";

@interface DocumentsMenuViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray<RATableItem *>*menuArray;

@end

@implementation DocumentsMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.menuArray = [NSMutableArray new];
    self.title = [@"Documents" localized];
    [self updateData];
}

- (UIUserInterfaceStyle)overrideUserInterfaceStyle {
    return UIUserInterfaceStyleLight;
}

- (void)updateData {
    __weak __typeof__(self) weakself = self;
    
    [self.menuArray removeAllObjects];
    RATableItem *driversLicense =
    [RATableItem itemWithTitle:[kDriversLicense localized] didSelectBlock:^(UITableViewCell *sender) {
        [weakself showDriversLicense];
    }];
    [self.menuArray addObject:driversLicense];
    
    if (self.cityDetail.tnc.isEnabled) {
        RATableItem *chauffeurPermit =
        [RATableItem itemWithTitle:self.cityDetail.tnc.headerText didSelectBlock:^(UITableViewCell *sender) {
            [weakself showChauffeurPermit];
        }];
        [self.menuArray addObject:chauffeurPermit];
    }
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menuArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RATableItem *item = self.menuArray[indexPath.row];
    DocumentsMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[DocumentsMenuTableViewCell className]];
    cell.textLabel.text = item.title;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    RATableItem *item = self.menuArray[indexPath.row];
    if (item.didSelectBlock) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        item.didSelectBlock(cell);
    }
}

#pragma mark - Navigation

- (void)showDriversLicense {
    LicenseDocumentViewController *licenseDocumentViewController = (LicenseDocumentViewController*)[self createViewControllerFromStoryboard:@"PersonalDocuments" withIdentifier:[LicenseDocumentViewController className]];
    licenseDocumentViewController.regConfig = [ConfigRegistration configWithCity:[ConfigurationManager getRegisteredCity]
                                                                       andDetail:self.cityDetail];
    [self.navigationController pushViewController:licenseDocumentViewController animated:YES];
}

- (void)showChauffeurPermit {
    DriverTNCViewController *vc = (DriverTNCViewController *)[self createViewControllerFromStoryboard:@"PersonalDocuments" withIdentifier:DriverTNCViewController.className];
    vc.regConfig = [ConfigRegistration configWithCity:[ConfigurationManager getRegisteredCity]
                                            andDetail:self.cityDetail];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
