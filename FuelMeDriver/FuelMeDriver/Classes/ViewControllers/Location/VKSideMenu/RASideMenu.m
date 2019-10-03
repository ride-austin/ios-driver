//
//  RASideMenu.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 12/8/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RASideMenu.h"

#import "ConfigurationManager.h"
#import "DirectConnectViewController.h"
#import "EditViewController.h"
#import "NSString+Utils.h"
#import "QueueViewController.h"
#import "RASessionManager.h"
#import "RASideMenuHeaderView.h"
#import "RASideMenuItem.h"
#import "RideDriver-Swift.h"
#import "RideDriverConstants.h"
#import "RideRequestTypeViewController.h"
#import "SettingsViewController.h"
#import "WeeklyEarningsViewController.h"
#import "RAAlertManager.h"

#import <SDWebImage/SDWebImageManager.h>

@interface RASideMenu()

@property (nonatomic, weak) UIViewController *presenter;
@property (nonatomic, strong, readwrite) NSMutableArray *menuItems;
@property (nonatomic, strong) NSArray<QueueZone *> *queueZones;
@property (nonatomic, strong) RASideMenuHeaderView *headerView;

@end

@interface RASideMenu (VKSideMenuDataSource) <VKSideMenuDataSource>
@end

@interface RASideMenu (VKSideMenuDelegate) <VKSideMenuDelegate>
@end

@implementation RASideMenu

+ (instancetype)configureWithPresenter:(UIViewController *)presenter {
    return [[self alloc] initWithPresenter:presenter];
}

- (instancetype)initWithPresenter:(UIViewController *)presenter {
    if (self = [super init]) {
        _presenter = presenter;
        _menuItems = [NSMutableArray new];
        [self configureObservers];
        [self configureMenu];
        
        ConfigGlobal *global  = [ConfigurationManager shared].global;
        RADriverDataModel *currentDriver = [RASessionManager shared].currentSession.driver;
        [self updateMenuItemsWithConfig:global andDriver:currentDriver];
        [self updateQueues];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)configureObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateQueues) name:kNotificationDidChangeConfiguration object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMenu) name:kCurrentDriverHasBeenChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hide) name:kDidSignoutNotification object:nil];
}

- (void)updateMenu {
    ConfigGlobal *global  = [ConfigurationManager shared].global;
    RADriverDataModel *currentDriver = [RASessionManager shared].currentSession.driver;
    [self updateMenuItemsWithConfig:global andDriver:currentDriver];
    [self.menu.tableView reloadData];
}

- (void)configureMenu {
    self.menu = [[VKSideMenu alloc] initWithWidth:250 andDirection:VKSideMenuDirectionLeftToRight];
    self.menu.dataSource = self;
    self.menu.delegate   = self;
    self.menu.enableOverlay   = YES;
    self.menu.hideOnSelection = YES;
    self.menu.iconsColor      = [UIColor azureBlue];
    self.menu.selectionColor  = [UIColor azureBlue];
    self.menu.textColor       = [UIColor whiteColor];
}

- (void)updateMenuItemsWithConfig:(ConfigGlobal *)global andDriver:(RADriverDataModel *)currentDriver {
    __weak __typeof__(self) weakself = self;
    [self.menuItems removeAllObjects];
    
    [self.menuItems addObject:[RASideMenuItem itemWithTitle:[@"Ride Request Type" localized] iconName:@"ridetypeMenu" block:^(UITableViewCell * _Nonnull cell) {
        if ([[DriverManager shared] isDriverOnActiveRide]) {
            [RAAlertManager showAlertWithTitle:[ConfigurationManager appName] message:[@"You cannot change ride type during trip." localized]];
        } else {
            [weakself.presenter performSegueWithIdentifier:RideRequestTypeViewController.className sender:nil];
        }
    }]];
    
    [self.menuItems addObject:[RASideMenuItem itemWithTitle:[@"Earnings" localized] iconName:@"report-icon" block:^(UITableViewCell * _Nonnull cell) {
        [weakself.presenter performSegueWithIdentifier:WeeklyEarningsViewController.className sender:nil];
    }]];
    
    ConfigDirectConnect *configDirectConnect = global.configDirectConnect;
    if ([global availableDCModeForDriver:currentDriver]) {
        [self.menuItems addObject:[RASideMenuItem itemWithTitle:configDirectConnect.title iconName:@"direct-connect-icon" block:^(UITableViewCell * _Nonnull cell) {
            [weakself showDirectConnectVC];
        }]];
    }
    
    //queues
    for (QueueZone *q in self.queueZones) {
        id iconName = q.iconUrl ?: @"menuAirportQueue";
        [self.menuItems addObject:[RASideMenuItem itemWithTitle:q.areaQueueName iconName:iconName block:^(UITableViewCell * _Nonnull cell) {
            [weakself showQueueVCWithQueue:q];
        }]];
    }
    
    //last
    [self.menuItems addObject:[RASideMenuItem itemWithTitle:[@"Settings" localized] iconName:@"settings-icon-active" block:^(UITableViewCell * _Nonnull cell) {
        [weakself.presenter performSegueWithIdentifier:SettingsViewController.className sender:nil];
    }]];

#ifdef QA
    if (currentDriver.user.hasAdminAvatar) {
        [self.menuItems addObject:[RASideMenuItem itemWithTitle:[@"ADMIN" localized] iconName:@"settings-icon-active" block:^(UITableViewCell * _Nonnull cell) {
            [weakself showAdminVC];
        }]];
    }
#endif
}

- (void)show {
    if (self.menu.isVisible) {
        [self.menu hide];
    } else {
        [self updateMenu];
        [self.menu show];
    }
}

- (void)hide {
    if (self.menu.isVisible) {
        [self.menu hide];
    }
}

#pragma mark - Queues

- (void)setQueueZones:(NSArray<QueueZone *> *)queueZones {
    _queueZones = queueZones;
    [self updateMenu];
}

- (void)updateQueues {
    __weak __typeof__(self) weakself = self;
    
    NSInteger cityId = [ConfigurationManager shared].global.currentCity.cityID.integerValue;
    [RAQueuesAPI getQueuesWithCityId:cityId completion:^(NSArray<QueueZone *> * _Nullable arrayQueues, NSError * _Nullable error) {
        if (error) {
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithShownOption:AllowNetworkError]];
        } else {
            weakself.queueZones = arrayQueues;
        }
    }];
}

#pragma mark - Routes

- (void)showEditProfileVCFromMenu {
    [self.menu hide];
    id vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:EditViewController.className];
    [self.presenter.navigationController pushViewController:vc animated:YES];
}

- (void)showDirectConnectVC {
    id vc = [[UIStoryboard storyboardWithName:@"DirectConnect" bundle:nil] instantiateViewControllerWithIdentifier:DirectConnectViewController.className];
    [self.presenter.navigationController pushViewController:vc animated:YES];
}

- (void)showAdminVC {
    id vc = [[UIStoryboard storyboardWithName:@"Admin" bundle:nil] instantiateViewControllerWithIdentifier:@"ADInputViewController"];
    [self.presenter.navigationController pushViewController:vc animated:YES];
}

- (void)showQueueVCWithQueue:(QueueZone *)queue {
    QueueViewController *vc = [[UIStoryboard storyboardWithName:@"AirportQueue" bundle:nil] instantiateViewControllerWithIdentifier:QueueViewController.className];
    vc.queue = queue;
    [self.presenter.navigationController pushViewController:vc animated:YES];
}

@end

@implementation RASideMenu (VKSideMenuDataSource)

- (NSInteger)numberOfSectionsInSideMenu:(VKSideMenu *)sideMenu {
    return 1;
}

- (NSInteger)sideMenu:(VKSideMenu *)sideMenu numberOfRowsInSection:(NSInteger)section {
    return self.menuItems.count;
}

- (VKSideMenuItem *)sideMenu:(VKSideMenu *)sideMenu itemForRowAtIndexPath:(NSIndexPath *)indexPath {
    RASideMenuItem *sideMenuItem = self.menuItems[indexPath.row];
    
    VKSideMenuItem *item = [VKSideMenuItem new];
    item.title = sideMenuItem.title;
    id iconImageName = sideMenuItem.iconName;
    if ([iconImageName isKindOfClass:[NSString class]]) {
        item.icon = [UIImage imageNamed:iconImageName];
    } else if ([iconImageName isKindOfClass:[NSURL class]]) {
        [[SDWebImageManager sharedManager] downloadImageWithURL:iconImageName options:SDWebImageHighPriority progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            item.icon = image;
            [sideMenu.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }];
    }
    
    return item;
}

- (UIView *)sideMenu:(VKSideMenu *)sideMenu headerViewForSection:(NSInteger)section {
    RADriverDataModel *driver = [RASessionManager shared].currentSession.driver;
    if (!self.headerView) {
        self.headerView = [RASideMenuHeaderView viewWithWidth:sideMenu.width target:self action:@selector(showEditProfileVCFromMenu)];
    }
    [self.headerView updateName:driver.firstname imageURL:driver.photoUrl];
    return self.headerView;
}

@end

@implementation RASideMenu (VKSideMenuDelegate)

- (void)sideMenu:(VKSideMenu *)sideMenu didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    sideMenu.tableView.userInteractionEnabled = NO; //RA-3525
    
    RASideMenuItem *item = self.menuItems[indexPath.row];
    if ([item.viewControllerName isKindOfClass:[NSString class]]) {
        id vc = [[NSClassFromString(item.viewControllerName) alloc] init];
        [self.presenter.navigationController pushViewController:vc animated:YES];
    } else if (item.didTapBlock) {
        UITableViewCell *cell = [sideMenu.tableView cellForRowAtIndexPath:indexPath];
        item.didTapBlock(cell);
    }
}

- (void)sideMenuDidShow:(VKSideMenu *)sideMenu {
    sideMenu.tableView.userInteractionEnabled = YES;
}

- (void)sideMenuDidHide:(VKSideMenu *)sideMenu {
    sideMenu.tableView.userInteractionEnabled = YES;
}

@end
