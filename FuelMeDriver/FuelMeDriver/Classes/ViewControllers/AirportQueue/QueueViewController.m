//
//  QueueViewController.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 8/15/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "QueueViewController.h"

#import "AQItem.h"
#import "AQTableViewCell.h"
#import "NSObject+className.h"
#import "RideDriver-Swift.h"
#import "RideDriverConstants.h"
#import "NSString+Utils.h"
#import "RAAlertManager.h"

#import <LGRefreshView/LGRefreshView.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <UIActivityIndicator_for_SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>

@interface QueueViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *lbDescription;
@property (strong, nonatomic) IBOutlet UIView *vTableHeader;
@property (strong, nonatomic) LGRefreshView *refreshView;
@property (nonatomic) NSArray<AQItem *> *arrayItems;
@property (nonatomic) BOOL hasPosition;

@end

@implementation QueueViewController

- (void)setHasPosition:(BOOL)hasPosition {
    _hasPosition = hasPosition;
    [self updateText];
}

- (void)updateText {
    NSString *outsideQ = [NSString stringWithFormat:[@"Numbers represent amount of drivers in the %@ queue" localized], self.queue.areaQueueName];
    NSString *insideQ = [NSString stringWithFormat:[@"Numbers represent your current spot in the %@ queue" localized], self.queue.areaQueueName];
    self.lbDescription.text = self.hasPosition ? insideQ : outsideQ;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurePullToRefresh];
    [self configureLayout];
    [self updateData];
    [self configureReachabilityObservers];
    self.title = self.queue.areaQueueName;
}

- (void)configurePullToRefresh {
    __weak __typeof__(self) weakself = self;
    self.refreshView = [LGRefreshView refreshViewWithScrollView:_tableView
                                                 refreshHandler:^(LGRefreshView *refreshView) {
                                                     [weakself updateTotalWithCompletion:^(NSError *error) {
                                                         [refreshView endRefreshing];
                                                         [weakself updatePosition];
                                                     }];
                                                 }];
    self.refreshView.tintColor = [UIColor darkGrayColor];
    self.tableView.scrollEnabled = YES;
}

- (void)configureLayout {
    self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
    self.view.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.00];
}

- (void)updateData {
    NSArray<RACarCategoryDataModel *> *carTypes = [ConfigurationManager shared].global.carTypes;
    [self configureArrayItemsFromCarCategories:carTypes];
}

- (void)configureArrayItemsFromCarCategories:(NSArray<RACarCategoryDataModel *> *)carCategories {
    NSMutableArray *mArray = [NSMutableArray new];
    for (RACarCategoryDataModel *category in carCategories) {
        if (category.shouldShowAreaQueue) {
            [mArray addObject:[AQItem itemWithCarCategory:category.carCategory displayName:category.title imageURL:category.iconURL]];
        }
    }
    self.arrayItems = mArray;
}

- (void)setArrayItems:(NSArray<AQItem *> *)arrayItems {
    _arrayItems = arrayItems;
    [self.tableView reloadData];
    
    __weak __typeof__(self) weakself = self;
    [self showHUD];
    [self updateTotalWithCompletion:^(NSError *error) {
        [weakself hideHUD];
        [weakself updatePosition];
    }];
    
}

- (void)updateTotalWithCompletion:(void(^)(NSError *error))completion {
    NSInteger cityId = [ConfigurationManager shared].global.currentCity.cityID.integerValue;
    [RAQueuesAPI getQueuesWithCityId:cityId completion:^(NSArray<QueueZone *> * _Nullable arrayQueues, NSError * _Nullable error) {
        if (error) {
            [self updateItemsTotalWithQueue];
            completion(error);
        } else {
            for (QueueZone *qzone in arrayQueues) {
                if ([qzone.areaQueueName isEqualToString:self.queue.areaQueueName]) {
                    self.queue = qzone;
                    [self updateItemsTotalWithQueue];
                }
            }
            completion(nil);
        }
    }];
}

- (void)updateItemsTotalWithQueue {
    for (AQItem *item in self.arrayItems) {
        [item setTotal:self.queue.lengths[item.carCategory]];
    }
}

- (void)updatePosition {
    NSNumber *driverId = [RASessionManager shared].currentSession.driver.modelID;
    
    [self showHUD];
    [[NetworkManager sharedInstance] getPositionForDriver:driverId withCompletion:^(NSDictionary *object, NSError *error) {
        [self hideHUD];
        if (object) {
            [self updatePositionsWithResponse:object];
        } else {
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive]];
        }
    }];
}

- (void)updatePositionsWithResponse:(NSDictionary *)response {
    self.hasPosition = NO;
    if ([self.queue.areaQueueName isEqualToString:response[@"areaQueueName"]]) {
        NSDictionary *positions = response[@"positions"];
        for (AQItem *item in self.arrayItems) {
            [item setPosition:positions[item.carCategory]];
            if (item.hasPosition) {
                self.hasPosition = YES;
            }
        }
    }
    [self.tableView reloadData];
}

#pragma mark - Reachability

- (void)configureReachabilityObservers {
    __weak __typeof__(self) weakself = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:kNetworkReachabilityStatusChanged
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^ (NSNotification *notification) {
                                                      NSNumber *statusNumber = (NSNumber *)notification.object;
                                                      AFRKNetworkReachabilityStatus status = [statusNumber intValue];
                                                      [weakself handleReachabilityStatusChange:status];
                                                  }];
}

- (void)handleReachabilityStatusChange:(AFRKNetworkReachabilityStatus)status {
    switch (status) {
        case AFRKNetworkReachabilityStatusReachableViaWiFi:
        case AFRKNetworkReachabilityStatusReachableViaWWAN:
            [self updateData];
            break;
        case AFRKNetworkReachabilityStatusUnknown:
        case AFRKNetworkReachabilityStatusNotReachable:
        default:
            break;
    }
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AQItem *item = self.arrayItems[indexPath.row];
    
    AQTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[AQTableViewCell className]];
    cell.lbType.text  = item.displayName;
    cell.lbCount.text = self.hasPosition ? item.displayPosition : item.displayTotal;
    [cell.ivIcon setImageWithURL:item.imageURL
                placeholderImage:[UIImage imageNamed:@"car_premium"]
                         options:SDWebImageHighPriority
                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                           
                       } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    return cell;
}

#pragma mark - QueueUpdateDelegate

- (void)queueUpdatedWithResponse:(NSDictionary *)response {
    if ([self.queue.areaQueueName isEqualToString:response[@"areaQueueName"]]) {
        [self updateData];
    }
}

@end
