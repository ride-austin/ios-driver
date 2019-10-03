//
//  DailyBasicCell.m
//  RideDriver
//
//  Created by Carlos Alcala on 7/18/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "DailyBasicCell.h"

#import "ConfigurationManager.h"
#import "NSDate+Utils.h"
#import "NSNumber+Utils.h"
#import "NSString+Utils.h"
#import "NetworkManager.h"
#import "RARideAPI.h"
#import "UIImage+Utils.h"

#import <SDWebImage/SDWebImageDownloader.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <UIActivityIndicator_for_SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>

@interface DailyBasicCell()
/**
 *  @brief 0 when hidden, 28 when visible. This will be removed when we make this as tableview
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintPriorityViewTop;
@property (weak, nonatomic) IBOutlet UIView *priorityFareView;

@end

@implementation DailyBasicCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.RAFeeTitle.text = [NSString stringWithFormat:[@"%@ Fee" localized], [ConfigurationManager appName]];
}

#pragma mark - Helper Functions

- (IBAction)contactUsAction:(UIButton *)sender {
    //callback delegate function
    [self.delegate sendEmailWithRide:self.currentRide];
}

- (IBAction)toggleAction:(UIButton *)sender {
    //execute block
    if (self.expandBlock != nil) {
        self.expandBlock();
    }
}

- (void)toggleExpand:(BOOL)expand {
    if (expand) {
        self.activeIcon.alpha = 0.0;
        self.activeIcon.hidden = NO;
        self.inactiveIcon.alpha = 0.0;
        self.inactiveIcon.hidden = YES;
        
        [UIView animateWithDuration:0.8 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.activeIcon.alpha = 1.0;
        } completion:^(BOOL done){
            
        }];
    } else {
        self.inactiveIcon.alpha = 0.0;
        self.inactiveIcon.hidden = NO;
        self.activeIcon.alpha = 0.0;
        self.activeIcon.hidden = YES;
        [UIView animateWithDuration:0.8 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.inactiveIcon.alpha = 1.0;
        } completion:^(BOOL done){
            
        }];
    }
}

- (void)configureCellWithRide:(RideFareDataModel*)ride {
    
    self.currentRide = ride;

    //setup header
    self.carLabel.text = [NSString stringWithFormat:@"%@ - %@", self.currentRide.requestedCarType.title, self.currentRide.car.fullDescription];
    self.timeLabel.text = [self.currentRide.completedOn reportTimeString];
    self.earningLabel.text = [self.currentRide.driverPayment currencyString];
    
    //setup map
    //self.iniLocation = [[CLLocation alloc] initWithLatitude:self.currentRide.startLocation.lat longitude:self.currentRide.startLocation.lng];
    //self.endLocation = [[CLLocation alloc] initWithLatitude:self.currentRide.endLocation.lat longitude:self.currentRide.endLocation.lng];
    
    //setup start/end locations
    self.startTimeLabel.text = [self.currentRide.startedOn reportTimeString];
    self.startAddressLabel.text = [self.currentRide.start fullAddress];
    self.endTimeLabel.text = [self.currentRide.completedOn reportTimeString];
    self.endAddressLabel.text = [self.currentRide.end fullAddress];
    
    //setup earnings detail
    self.baseFareValue.text = [self.currentRide.baseFare currencyString];
    self.distanceFareValue.text = [self.currentRide.distanceFare currencyString];
    self.timeFareValue.text = [self.currentRide.timeFare currencyString];
    self.RAFeeValue.text = [self.currentRide.raFee currencyString];
    self.totalFareValue.text = [self.currentRide.subTotal currencyString];
    self.tipValue.text         = self.currentRide.tip.currencyString;
    self.yourEarningValue.text = [self.currentRide.driverPayment currencyString];
    self.priorityFareTitle.text = [NSString stringWithFormat:[@"Priority Fare (%@X)" localized], self.currentRide.surgeFactor];
    self.priorityFareValue.text = [self.currentRide.surgeFare currencyString];
    BOOL shouldHidePriorityFareView = self.currentRide.surgeFare.doubleValue == 0;
    
    self.priorityFareView.hidden = shouldHidePriorityFareView;
    self.constraintPriorityViewTop.constant = shouldHidePriorityFareView ? 0 : 28;
    
    //load map URL and show image
    [self loadMapURL];
}

- (void)loadMapURL {

    //avoid API callback if the mapURL already exists
    if (self.mapURL != nil) {
        //async download image
        [self loadMapImage];
        
        return;
    }
    
    __weak DailyBasicCell *weakSelf = self;
    [RARideAPI getMapURLForRideWithId:[self.currentRide.modelID stringValue] andCompletion:^(NSURL *mapURL, NSError *error) {
        if (!error && mapURL) {
            weakSelf.mapURL = mapURL;
            [weakSelf loadMapImage];
        }
    }];
}

- (void)loadMapImage {
    __weak DailyBasicCell *weakSelf = self;
    [self.mapImageView setImageWithURL:self.mapURL placeholderImage:nil options:0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
         if (!error) {
             UIImage *resizedImage = [UIImage resizeImage:image size:weakSelf.mapImageView.frame.size withInterpolationQuality:kCGInterpolationHigh];
             weakSelf.mapImageView.image = resizedImage;
         }
     } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    //cleanup the map URL and image
    self.mapURL = nil;
    self.mapImageView.image = nil;
    self.activeIcon.hidden = YES;
    self.inactiveIcon.hidden = NO;
    self.inactiveIcon.alpha = 1.0;
}

@end
