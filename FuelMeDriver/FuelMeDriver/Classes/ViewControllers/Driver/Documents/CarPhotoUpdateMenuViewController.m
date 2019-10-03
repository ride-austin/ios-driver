//
//  CarPhotoUpdateMenuViewController.m
//  RideDriver
//
//  Created by Abdul Rehman on 08/11/2016.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "CarPhotoUpdateMenuViewController.h"

#import "CarPhotoUpdateCell.h"
#import "CarPhotoUpdateViewController.h"
#import "NSString+Utils.h"

#import <UIActivityIndicator_for_SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>

static NSString * const kReuseCellIdentifier = @"CarPhotoUpdateCell";

@interface CarPhotoUpdateMenuViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic,strong) NSMutableDictionary *carPhotosDictionary;

@end


@implementation CarPhotoUpdateMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = [@"Vehicle Information" localized];

    [self.carCollectionView registerNib:[UINib nibWithNibName:@"CarPhotoUpdateCell" bundle:nil] forCellWithReuseIdentifier:kReuseCellIdentifier];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self fillData];
}

#pragma mark - Pre fill Data

- (NSMutableDictionary*)carPhotosDictionary {
    if (_carPhotosDictionary == nil) {
        _carPhotosDictionary = [NSMutableDictionary new];
        
        for (int i=0; i < self.typesArray.count; i++) {
            CarPhotoType type = [[self.typesArray objectAtIndex:i] intValue];
            CarPhotoUpdate *photo = [[CarPhotoUpdate alloc] initWithType:type];
            [_carPhotosDictionary setObject:photo forKey:[NSString getPhotoTypeStringWithCarPhotoType:type]];
        }
    }
    return _carPhotosDictionary;
}

- (NSArray*)typesArray {
    return @[@(FrontPhoto),@(BackPhoto),@(InsidePhoto),@(TrunkPhoto)];
}

#pragma mark- Data Source

- (void)fillData {
    [self showHUD];
    [[NetworkManager sharedInstance] getCarPhotosWithCarID:self.carID andCompletionBlock:^(NSArray *carPhotos, NSError *error) {
        [self hideHUD];
        if (!error) {
            for (NSDictionary *photo in carPhotos) {
                CarPhotoUpdate *update = [[CarPhotoUpdate alloc] initWithDictionary:photo];
                [self.carPhotosDictionary setObject:update forKey:[NSString getPhotoTypeStringWithCarPhotoType:update.type]];
            }
            [self.carCollectionView reloadData];
        }
    }];
}

#pragma mark - UICOLLECTION VIEW DELEGATE AND DATASOURCE

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.carPhotosDictionary.count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CarPhotoUpdateCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kReuseCellIdentifier forIndexPath:indexPath];
    cell.layer.borderColor = [UIColor clearColor].CGColor;
    
    CarPhotoUpdate *carPhotoUpdate = [self carPhotoUpdateByIndex:indexPath];
    cell.lblTitle.text = carPhotoUpdate.topTitlePhoto;
    cell.imgPlaceHolder.image = carPhotoUpdate.placeHolder;
    
    [cell.imgCar setImageWithURL:[NSURL URLWithString:carPhotoUpdate.imgUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        cell.imgCar.image = image;
        cell.imgPlaceHolder.image = nil;
    } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    //Add target
    [cell.btnUpdate addTarget:self action:@selector(updatePressed:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    const CGFloat horizontalMargin = 34;
    const CGFloat verticalMargin = 64;
    const CGFloat numberOfElementsToFit = 2;
    
    CGFloat itemWidth = (collectionView.bounds.size.width - horizontalMargin) / numberOfElementsToFit;
    CGFloat itemHeight = (collectionView.bounds.size.height - verticalMargin) / numberOfElementsToFit;
    
    return CGSizeMake(itemWidth, itemHeight);
}

- (CarPhotoUpdate*)carPhotoUpdateByIndex:(NSIndexPath*)indexPath {
    CarPhotoType carPhotoType = [[[self typesArray] objectAtIndex:indexPath.row] intValue];
    NSString *key = [NSString getPhotoTypeStringWithCarPhotoType:carPhotoType];
    return [self.carPhotosDictionary objectForKey:key];
}

#pragma mark - Update button Pressed

- (void)updatePressed:(UIButton*)updateButton {
    CGPoint touchLocation = [updateButton convertPoint:CGPointZero toView:self.carCollectionView];
    NSIndexPath *indexPath = [self.carCollectionView indexPathForItemAtPoint:touchLocation];
    if (indexPath) {
        CarPhotoUpdate *carPhotoUpdate = [self carPhotoUpdateByIndex:indexPath];
        [self openUpdateViewControllerWithCarPhoto:carPhotoUpdate];
    }
}

#pragma mark - Navigate to Detail View Controllers

- (void)openUpdateViewControllerWithCarPhoto:(CarPhotoUpdate*)carPhoto {
    CarPhotoUpdateViewController *backVC = [[CarPhotoUpdateViewController alloc] initWithNibName:@"CarPhotoUpdateViewController" bundle:nil];
    backVC.carPhoto = carPhoto;
    backVC.carID = self.carID;
    [self.navigationController pushViewController:backVC animated:YES];
}

@end
