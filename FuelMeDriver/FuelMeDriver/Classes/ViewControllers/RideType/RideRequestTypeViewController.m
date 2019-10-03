//
//  RideRequestTypeViewController.m
//  RideDriver
//
//  Created by Abdul Rehman on 25/06/2016.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "RideRequestTypeViewController.h"

#import "RADriversAPI.h"
#import "RideDriver-Swift.h"
#import "RideDriverConstants.h"
#import "RideRequestTypeFooterCollectionReusableView.h"
#import "RideRequestTypeHeaderCollectionReusableView.h"
#import "RideTypeCollectionViewCell.h"
#import "RAAlertManager.h"

#import <SDWebImage/UIImageView+WebCache.h>

static NSString *kReloadCategoriesImageNotification = @"kReloadCategoriesImageNotification";

@interface RideRequestTypeViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, RideRequestTypeScreenViewModelProtocol>

//IBOutlets
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btSave;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

//Properties
@property (nonatomic) RideRequestTypeScreenViewModel *viewModel;
@property (strong, nonatomic) NSArray<RACarCategoryDataModel *> *carTypesAvailableInCurrentCity;
@property (nonatomic) BOOL needsToConfigureCar; //no need to update car multiple times
@end

@implementation RideRequestTypeViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureObservers];
    [self configureDefaultUI];
    [self configureCollectionView];
    
    self.viewModel = [[RideRequestTypeScreenViewModel alloc] initWithSessionManager:[RASessionManager shared] configManager:[ConfigurationManager shared] delegate:self];
    [self configureSelectedCar];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Configure UI

- (void)configureDefaultUI {
    self.btSave.enabled = NO;
}

- (void)configureCollectionView {
    [self.collectionView registerNib:[UINib nibWithNibName:RideTypeCollectionViewCell.className bundle:nil] forCellWithReuseIdentifier:RideTypeCollectionViewCell.className];
}

- (void)setViewModel:(RideRequestTypeScreenViewModel *)viewModel {
    _viewModel = viewModel;
    self.title = _viewModel.title;
    [self.collectionView reloadData];
}

#pragma mark - Observers

- (void)configureObservers {
    __weak RideRequestTypeViewController *weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:kReloadCategoriesImageNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [weakSelf.collectionView reloadData];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kNetworkReachabilityStatusChanged object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull notification) {
        NSNumber *statusNumber = (NSNumber *)notification.object;
        AFRKNetworkReachabilityStatus status = [statusNumber intValue];
        if (status == AFRKNetworkReachabilityStatusReachableViaWiFi || status == AFRKNetworkReachabilityStatusReachableViaWWAN) {
            if (weakSelf.needsToConfigureCar) {
                [weakSelf configureSelectedCar];
            }
        }
    }];
}

#pragma mark - API Methods

- (void)configureSelectedCar {
    __weak RideRequestTypeViewController *weakSelf = self;
    [self showHUD];
    [self.viewModel reloadSelectedCarWithCompletion:^(NSError *error) {
        [weakSelf hideHUD];
        if (error) {
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive andShownOption:AllowNetworkError]];
            [weakSelf.btSave setEnabled:NO];
        }
        weakSelf.needsToConfigureCar = error != nil;
    }];
}

#pragma mark - IBActions

- (IBAction)btSavePressed:(UIBarButtonItem *)sender {
    [self.viewModel didSaveWithCompletion:^(NSString *errorMessage) {
        if (errorMessage) {
            [RAAlertManager showErrorWithAlertItem:errorMessage andOptions:[RAAlertOption optionWithState:StateActive]];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (void)segmentedControlChanged:(UISegmentedControl *)sender {
    [self.viewModel didSelectFilterWithIndex:sender.selectedSegmentIndex sender:sender];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.viewModel.carTypeViewModels.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        RideRequestTypeHeaderCollectionReusableView *headerView = (RideRequestTypeHeaderCollectionReusableView*)[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"header" forIndexPath:indexPath];
        headerView.lblCarName.text = self.viewModel.displayCarName;;
        return headerView;
    } else {
        RideRequestTypeFooterCollectionReusableView *footerView = (RideRequestTypeFooterCollectionReusableView*)[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"footer" forIndexPath:indexPath];
        
        if (footerView.segmentedControl == nil && self.viewModel.shouldShowDriverTypeFilter) {
            footerView.segmentedControl = [self.viewModel setupSegmentedControlWithTarget:self action:@selector(segmentedControlChanged:)];
        }
        footerView.constraintHeightDriverTypeSwitch.constant = self.viewModel.shouldShowDriverTypeFilter ? 50.0 : 0;
        footerView.lblCategoryDescription.text = self.viewModel.selectionDescription;
        [footerView setNeedsLayout];
        [footerView layoutIfNeeded];
        return footerView;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RideTypeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:RideTypeCollectionViewCell.className forIndexPath:indexPath];
    
    CarTypeViewModel *vm = self.viewModel.carTypeViewModels[indexPath.row];
    cell.lblCarType.text     = vm.displayName;
    cell.imgBackground.image = vm.backgroundImage;
    cell.imgSelected.hidden  = vm.isSelected == NO;

    if (vm.iconURL) {
        [cell.imgCar sd_setImageWithURL:vm.iconURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            UIImage *templateImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            cell.imgCar.image = templateImage;
            cell.imgCar.tintColor = vm.tintColor;
        }];
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewModel didSelectCarWithIndex:indexPath.row];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    CGFloat margin = 13;
    CGSize size = CGSizeMake(collectionView.bounds.size.width - (2 * margin), CGFLOAT_MAX);
    NSDictionary *attributes = @{NSFontAttributeName : [UIFont fontWithName:@"Montserrat-Light" size:12.0]};
    CGRect descriptionRect = [self.viewModel.selectionDescription boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    CGFloat filterHeight = self.viewModel.shouldShowDriverTypeFilter ? 50.0 : 0.0;
    return CGSizeMake(size.width, descriptionRect.size.height + filterHeight + margin * 2);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat margin = 13.0;
    CGFloat spacing = 10.0;
    CGFloat width = floor((collectionView.bounds.size.width - (2*margin) - (2*spacing)) / 3.0);
    return CGSizeMake(width, 80);
}

#pragma mark - RideRequestTypeScreenViewModelProtocol

- (void)didUpdateDataSource {
    self.btSave.enabled = self.viewModel.canSave;
    [self.collectionView reloadData];
}

@end
