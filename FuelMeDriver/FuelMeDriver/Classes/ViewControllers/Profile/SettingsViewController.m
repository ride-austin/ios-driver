//
//  SettingsViewController.m
//  Ride
//
//  Created by Tyson Bunch on 5/19/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "SettingsViewController.h"

#import "CarSelectionViewController.h"
#import "DocumentsMenuViewController.h"
#import "DriverPhotoViewController.h"
#import "DriverStatisticViewController.h"
#import "EditViewController.h"
#import "NSObject+className.h"
#import "NSString+Utils.h"
#import "NavigationAppUtil.h"
#import "RACallKitManager.h"
#import "RARideCacheManager.h"
#import "SMessageViewController.h"
#import "SettingsSection.h"
#import "TermAndConditionViewController.h"
#import "UIColor+HexUtils.h"
#import "RAEnvironmentManager.h"
#import "RAAlertManager.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <UIActivityIndicator_for_SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>

static NSString * const kLike                   = @"Like us on Facebook";
static NSString * const kLegal                  = @"Legal";
static NSString * const kSupport                = @"Contact Support";
static NSString * const kSignout                = @"Sign out";

static NSString * const kDefaultNavigationApp   = @"Default Navigation App";
static NSString * const kCallSetting            = @"Call action";
static NSString * const kUpdateDocuments        = @"Update Documents";
static NSString * const kMyCars                 = @"My Cars";

static CGFloat const kFeatureViewTag = 9999;

#define kScreenTitle @"Settings"

@interface SettingsViewController ()  <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) NSMutableArray<SettingsSection *> *sections;
@property (nonatomic) NSMutableArray *data;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UILabel *name;
@property (nonatomic, weak) IBOutlet UIImageView *avatarImage;

@end

@implementation SettingsViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = kScreenTitle.localizedCapitalizedString;
    
    self.sections = [NSMutableArray new];
    [self configureTable];
    [self configureObservers];
    [self updateData];
    if (@available(iOS 13.0, *)) {
        self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.accessibilityIdentifier = kScreenTitle;
    
    RADriverDataModel *driver = [RASessionManager shared].currentSession.driver;
    self.name.text = driver.user.fullName;
    
    UIImage *placeholder = [UIImage imageNamed:@"Icon-user"];
    if ([driver.photoUrl isKindOfClass:[NSURL class]]) {
        [self.avatarImage setImageWithURL:driver.photoUrl placeholderImage:placeholder options:SDWebImageHighPriority completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
             if (!error) {
                 // FIX: iOS10 No need to reasign the image again here
             }
         } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    } else {
        self.avatarImage.image = placeholder;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)configureTable {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setScrollEnabled: YES];
    
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setFont:[UIFont fontWithName:@"Montserrat-Regular" size:12]];
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setTextColor:[UIColor colorWithRed:7.0/255.0 green:13.0/255.0 blue:22.0/255.0 alpha:1.0]];
}

- (void)configureObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateData) name:kNotificationDidChangeCurrentCityType object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateData) name:kNotificationDidAcceptedTermsAndConditions object:nil];
}

- (void)updateData {
    __weak __typeof__(self) weakself = self;
    
    SettingsItem *fb = [SettingsItem itemWithTitle:[kLike localized] mainURL:self.generalInfo.facebookUrl];
    
    SettingsItem *legal = [SettingsItem itemWithTitle:[kLegal localized] mainURL:self.generalInfo.privacyStatementURL];
    
    SettingsItem *web = [SettingsItem itemWithTitle:self.generalInfo.companyDomain
                        mainURL:self.generalInfo.companyWebsite];
    
    SettingsItem *support = [SettingsItem itemWithTitle:[kSupport localized] didSelectBlock:^(UITableViewCell *sender) {
        [weakself showMessageViewWithRideID:nil];
    }];
    
    SettingsItem *myCars = [SettingsItem itemWithTitle:[kMyCars localized] didSelectBlock:^(UITableViewCell *sender) {
        [weakself showMyCars];
    }];
    
    SettingsItem *updateDocumentsSettings = [SettingsItem itemWithTitle:[kUpdateDocuments localized] didSelectBlock:^(UITableViewCell *sender) {
        [weakself attemptToShowDocuments];
    }];
    
    NSString *aboutWithVersion = [NSString stringWithFormat:[@"ABOUT - %@" localized], [RAEnvironmentManager sharedManager].version];
    SettingsSection *section1 = [SettingsSection sectionWithTitle:aboutWithVersion];
    [section1 addObject:fb];
    [section1 addObject:legal];
    [section1 addObject:web];
    [section1 addObject:support];
    [section1 addObject:myCars];
    
    if ([ConfigurationManager shared].global.shouldShowDriverStats) {
        SettingsItem *myStats = [SettingsItem itemWithTitle:[@"My Stats" localized] didSelectBlock:^(UITableViewCell *sender) {
            [weakself showMyStats];
        }];
        [section1 addObject:myStats];
    }
    
    [section1 addObject:updateDocumentsSettings];
    
    if ([RACallKitManager isCallKitAvailable]) {
        SettingsItem *acceptCallOptions =
        [SettingsItem itemWithTitle:[kCallSetting localized] didSelectBlock:^(UITableViewCell *sender) {
            [weakself showAcceptCallOptions:sender];
        }];
        acceptCallOptions.subTitle = [RACallKitManager nameFromOption:[PersistenceManager cachedCallSetting]];
        acceptCallOptions.cellStyle = UITableViewCellStyleSubtitle;
        acceptCallOptions.cellIdentifier = @"SettingCellSubtitle";
        [section1 addObject:acceptCallOptions];
    }
    
    NSString *currentNavigationApp = [PersistenceManager hasDefaultNavigationApp] ? [NavigationAppUtil nameApp:[PersistenceManager cachedDefaultNavigationApp]] : @"";
    
    SettingsItem *navigationOptions = [SettingsItem itemWithTitle:[kDefaultNavigationApp localized] didSelectBlock:^(UITableViewCell *sender) {
        [weakself showNavigationOptions:sender];
    }];
    navigationOptions.subTitle  = currentNavigationApp;
    navigationOptions.cellStyle = UITableViewCellStyleSubtitle;
    navigationOptions.cellIdentifier = @"SettingCellSubtitle";
    [section1 addObject:navigationOptions];
    
    if ([RASessionManager shared].currentSession.driver.agreedToLegalTerms == NO) {
        SettingsItem *newTerms = [SettingsItem itemWithTitle:[@"New Terms & Conditions" localized] didSelectBlock:^(UITableViewCell *sender) {
            [weakself performSegueWithIdentifier:[SettingsViewController segueTo:[TermAndConditionViewController class]] sender:nil];
        }];
        newTerms.featured = YES;
        [section1 addObject:newTerms];
    }
    
    SettingsItem *signout = [SettingsItem itemWithTitle:[kSignout localized] didSelectBlock:^(UITableViewCell *sender) {
        [weakself attemptToSignout];
    }];
    signout.accessoryType = UITableViewCellAccessoryNone;
    SettingsSection *section2 = [SettingsSection sectionWithTitle:@"    "];
    [section2 addObject:signout];
    [self.sections removeAllObjects];
    [self.sections addObject:section1];
    [self.sections addObject:section2];
    [self.tableView reloadData];
}

- (RAGeneralInfo *)generalInfo {
    return [ConfigurationManager shared].global.generalInfo;
}

#pragma mark - UITableView stuff

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sections[section].title;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sections[section].items.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SettingsItem *item = self.sections[indexPath.section].items[indexPath.row];
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:item.cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:item.cellStyle reuseIdentifier:item.cellIdentifier];
        cell.detailTextLabel.font = [UIFont fontWithName:@"Montserrat-Light" size:10];
        cell.textLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:12];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        
        UIView *featuredView = [[UIView alloc] init];
        [featuredView setTag:kFeatureViewTag];
        [featuredView setBackgroundColor:[UIColor colorWithHex:@"#ff2222"]];
        [[featuredView layer] setCornerRadius:5];
        [cell.contentView addSubview:featuredView];
    }
    
    cell.textLabel.textColor       = [UIColor colorWithRed:60.0/255.0 green:67.0/255.0 blue:80.0/255.0 alpha:1.0];
    cell.detailTextLabel.textColor = [UIColor colorWithRed:60.0/255.0 green:67.0/255.0 blue:80.0/255.0 alpha:1.0];
    if ([item.title isEqualToString:kSignout]) {
        cell.textLabel.textColor = [UIColor colorWithRed:2.0/255.0 green:167.0/255.0 blue:249.0/255.0 alpha:1.0];
    }
    
    cell.accessoryType        = item.accessoryType;
    cell.textLabel.text       = item.title;
    cell.detailTextLabel.text = item.subTitle;
    
    UIView *featuredView = [cell.contentView viewWithTag:kFeatureViewTag];
    featuredView.hidden = !item.featured;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingsItem *item = self.sections[indexPath.section].items[indexPath.row];
    if (item.featured) {
        CGRect cellBounds = cell.contentView.bounds;
        CGFloat featuredSize = 10;
        UIView *featuredView = [cell.contentView viewWithTag:kFeatureViewTag];
        featuredView.frame = CGRectMake(cellBounds.size.width - 10, CGRectGetMidY(cellBounds) - featuredSize/2, featuredSize, featuredSize);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SettingsItem *item = self.sections[indexPath.section].items[indexPath.row];
    UIApplication *app = [UIApplication sharedApplication];
    if (item.didSelectBlock) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        item.didSelectBlock(cell);
    } else if ([app canOpenURL:item.mainURL]) {
        [app openURL:item.mainURL];
    } else if ([app canOpenURL:item.secondaryURL]) {
        [app openURL:item.secondaryURL];
    }
}

#pragma mark - Navigation

- (void)showMyCars {
    [self showHUD];
    
    RADriverDataModel *driver = [RASessionManager shared].currentSession.driver;
    RACity *registeredCity = [ConfigurationManager getCityWithID:driver.cityId];
    [NetworkManager getCityDetailWithID:driver.cityId withCompletion:^(RACityDetail *cityDetail, NSError *error) {
        [self hideHUD];
        if (error) {
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive]];
        } else {
            CarSelectionViewController *vc = [[UIStoryboard storyboardWithName:@"DriverCars" bundle:nil] instantiateViewControllerWithIdentifier:[CarSelectionViewController className]];
            [vc configureWithCityDetail:cityDetail
                         registeredCity:registeredCity
                            andDriverID:driver.modelID.stringValue];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];
}

- (void)showMyStats {
    DriverStatisticViewController *driverStatisticViewController = (DriverStatisticViewController*)[self createViewControllerFromStoryboard:@"DriverStats" withIdentifier:@"DriverStatisticViewController"];
    [self.navigationController pushViewController:driverStatisticViewController animated:YES];
}

- (void)showNavigationOptions:(UITableViewCell *)cell {
    UIAlertController *ac =
    [UIAlertController alertControllerWithTitle:[@"Navigation App" localized]
                                        message:[@"Which app do you prefer as default?" localized]
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    ac.popoverPresentationController.sourceView = cell.contentView;
    [ac addAction:[UIAlertAction actionWithTitle:@"Waze"
                                           style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * _Nonnull action) {
        [self didSelectNavigationApp:WazeApp];
    }]];
    
    [ac addAction:[UIAlertAction actionWithTitle:@"Google Maps"
                                           style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * _Nonnull action) {
        [self didSelectNavigationApp:GoogleMapApp];
    }]];
    
    [ac addAction:[UIAlertAction actionWithTitle:@"Apple Maps"
                                           style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * _Nonnull action) {
        [self didSelectNavigationApp:AppleMaps];
    }]];
    
    [ac addAction:[UIAlertAction actionWithTitle:[@"Cancel" localized]
                                           style:UIAlertActionStyleCancel
                                         handler:nil]];
    
    [self presentViewController:ac animated:YES completion:nil];
}

- (void)didSelectNavigationApp:(NavigationApp)navigationApp {
    if ([[UIApplication sharedApplication] canOpenURL:[NavigationAppUtil urlToOpen:navigationApp]]){
        [PersistenceManager saveDefaultNavigationApp:navigationApp];
        [self updateData];
    }else{
        [self showAlertToInstallNavigationApp:navigationApp];
    }
}

- (void)showAcceptCallOptions:(UITableViewCell *)cell {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:[@"Call Action" localized] message:[@"Which option you prefer to perform when receive a request call?" localized] preferredStyle:UIAlertControllerStyleActionSheet];
    
    [ac addAction:[UIAlertAction actionWithTitle:[@"Accept Request" localized] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [PersistenceManager saveCallSetting:AcceptRequest];
        [self updateData];
    }]];
    
    [ac addAction:[UIAlertAction actionWithTitle:[@"Open App" localized] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [PersistenceManager saveCallSetting:OpenApp];
        [self updateData];
    }]];
    
    [ac addAction:[UIAlertAction actionWithTitle:[@"Cancel" localized] style:UIAlertActionStyleCancel handler:nil]];
    ac.popoverPresentationController.sourceView = cell.contentView;
    [self presentViewController:ac animated:YES completion:nil];
}

- (void)attemptToShowDocuments {
    NSNumber *cityId = [RASessionManager shared].currentSession.driver.cityId;
    
    [self showHUD];
    [NetworkManager getCityDetailWithID:cityId withCompletion:^(RACityDetail *cityDetail, NSError *error) {
        [self hideHUD];
        if (error) {
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive]];
        } else {
            [self showUpdateDocumentsWithCityDetail:cityDetail];
        }
    }];
    
}

- (void)showUpdateDocumentsWithCityDetail:(RACityDetail *)cityDetail {
    DocumentsMenuViewController *vc = (DocumentsMenuViewController*)[self createViewControllerFromStoryboard:@"DocumentsUpdate" withIdentifier:[DocumentsMenuViewController className]];
    vc.cityDetail = cityDetail;
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 Check for cache to flush before going offline
 DriverManager will handle the case when driver is on a trip
 */
- (void)attemptToSignout {
#ifdef AUTOMATION
    [[RARideCacheManager sharedManager] removeCache];
#endif
    if ([RARideCacheManager sharedManager].hasCacheToFlush) {
        NSString *message = [@"Please check your internet connection. You'll be able to signout once connection is established." localized];
        [RAAlertManager showAlertWithTitle:[ConfigurationManager appName] message:message options:[RAAlertOption optionWithState:StateActive]];
    } else {
        [self showHUD];
        [[DriverManager shared] goOfflineWithCompletion:^(DriverState driverState, NSError * _Nullable error) {
            if (error) {
                [self hideHUD];
                [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateAll andShownOption:AllowNetworkError]];
            } else {
                [[RASessionManager shared] logoutWithCompletion:^(NSError * _Nullable error) {
                    [self hideHUD];
                }];
            }
        }];
    }
}

- (IBAction)didTapPhoto:(UIButton *)sender {
    DriverPhotoViewController *vc = [[UIStoryboard storyboardWithName:@"DriverProfile" bundle:nil] instantiateViewControllerWithIdentifier:[DriverPhotoViewController className]];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Support Message View Controller

- (void)showMessageViewWithRideID:(NSString *)rideID {
    SMessageViewController *vc = [[UIStoryboard storyboardWithName:@"Support" bundle:nil] instantiateViewControllerWithIdentifier:[SMessageViewController className]];
    vc.rideID = rideID;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
