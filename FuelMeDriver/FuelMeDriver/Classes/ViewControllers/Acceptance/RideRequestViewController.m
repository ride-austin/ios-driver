//
//  RequestViewController.m
//  RideDriver
//
//  Created by Roberto Abreu on 31/10/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "RideRequestViewController.h"
#import "RideAttributesView.h"
#import "LocationService.h"
#import "NSDate+Utils.h"
#import "UIBarButtonItem+RABarButton.h"
#import "NSString+Utils.h"

#import <SDWebImage/UIImageView+WebCache.h>

#define kTopZIndex 9999
#define kLocationViewControllerMapDefaultZoomAdjustment 4
#define kGreenAcceptColor [UIColor colorWithRed:1.0/255.0 green:188.0/255.0 blue:0 alpha:1]
#define kPinkAcceptColor [UIColor colorWithRed:249/255.0 green:38.0/255.0 blue:141.0/255.0 alpha:1]
#define kBlueAcceptColor [UIColor colorWithRed:2.0/255.0 green:167.0/255.0 blue:249.0/255.0 alpha:1]
#define kGreenCountDownColor [UIColor colorWithRed:2.0/255.0 green:160.0/255.0 blue:1.0/255.0 alpha:1]
#define kPinkCountDownColor [UIColor colorWithRed:233.0/255.0 green:3.0/255.0 blue:115.0/255.0 alpha:1]
#define kBlueCountDownColor [UIColor colorWithRed:6.0/255.0 green:145.0/255.0 blue:214.0/255.0 alpha:1]
#define kBtnDeclineForegroundColor [UIColor colorWithRed:29.0/255.0 green:169.0/255.0 blue:247.0/255.0 alpha:1]

@interface RideRequestViewController ()

@property (nonatomic, strong) GMSMarker *userMarker;
@property (nonatomic, strong) GMSMarker *carMarker;
@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic) UIBarButtonItem *btnDecline;
@property (nonatomic) BOOL viewDidLayoutSubviewAlreadyCalled;

@property (weak, nonatomic) IBOutlet UIView *attributesView;

@end

@implementation RideRequestViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addObservers];
    RideAttributesView *attributesView = [[RideAttributesView alloc] initWithFrame:self.attributesView.bounds andRide:self.rideDataModel];
    attributesView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.attributesView addSubview:attributesView];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self invalidateTimer];
    self.internalWindow.hidden = YES;
    self.internalWindow = nil;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (!self.viewDidLayoutSubviewAlreadyCalled) {
        [self.googleMapView layoutIfNeeded];
        self.viewDidLayoutSubviewAlreadyCalled = YES;
        [self configureUI];
        [self configureLayoutIfNeeded];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (RARideDataModel *)rideDataModel {
    return self.event.isStackedRide ? self.event.nextRide : self.event.ride;
}

- (void)addObservers {
    __weak RideRequestViewController *weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {

        if (weakSelf.event.remainingAcceptanceExpiration <= 0 && [weakSelf.timer isValid]) {
            [weakSelf dismissRequestView];
            
            if (weakSelf.rideRequestDelegate) {
                [weakSelf.rideRequestDelegate didTimerFinishForEvent:self.event];
            }
        }
    }];
}

- (void)configureAccessibility {
    self.navigationController.navigationBar.accessibilityIdentifier = @"RideRequestScreen";
    self.view.accessibilityLabel = @"RideRequestView";
    self.lblETA.accessibilityLabel = @"lblETA";
    self.lblPrimaryAddress.accessibilityLabel = @"lblPrimaryAddress";
    self.lblRiderRating.accessibilityLabel = @"lblRiderRating";
    self.lblRiderUsername.accessibilityLabel = @"lblRiderUsername";
    self.imgRider.accessibilityLabel = @"imgRider";
    self.btnAccept.accessibilityLabel = @"btnAccept";
    self.lblSecondsAvailable.accessibilityIdentifier = @"lblCountDown";
    self.googleMapView.accessibilityElementsHidden = NO;
    self.googleMapView.accessibilityLabel = @"GoogleMapRideRequest";
    
    if ([self.rideDataModel containsDriverType:DriverTypeFemaleDriver]) {
        self.btnAccept.accessibilityValue = [NSString stringWithFormat:@"Accept \nFEMALE DRIVER,%@",kPinkAcceptColor.description];
        self.lblSecondsAvailable.accessibilityValue = kPinkCountDownColor.description;

    } else if (self.rideDataModel.hasSurgeFactor) {
        self.btnAccept.accessibilityValue = [NSString stringWithFormat:@"Accept,%@",kBlueAcceptColor.description];
        self.lblSecondsAvailable.accessibilityValue = kBlueCountDownColor.description;
        
    } else {
        self.btnAccept.accessibilityValue = [NSString stringWithFormat:@"Accept,%@",kGreenAcceptColor.description];
        self.lblSecondsAvailable.accessibilityValue = kGreenCountDownColor.description;
    }
}

- (void)configureUI {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    //Setup Shadows
    self.vInformationRequestContainer.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.2].CGColor;
    
    //Configure Accessibility
    [self configureAccessibility];
    
    //Setup Btn Online
    if (self.event.isStackedRide) {
        self.navigationItem.titleView = nil;
    } else {
        [self.driverStatusButton setStatusBasedOnAvailability];
    }
    
    //Setup Google Map View
    self.googleMapView.indoorEnabled = NO;
    self.googleMapView.settings.allowScrollGesturesDuringRotateOrZoom = NO;
    self.googleMapView.settings.scrollGestures = NO;
    self.googleMapView.mapType = kGMSTypeNormal;
    self.googleMapView.settings.rotateGestures = NO;
    self.googleMapView.myLocationEnabled = NO;
    self.googleMapView.settings.zoomGestures = NO;
    
    
    //Setup ETA
    self.lblETA.text = self.rideDataModel.eta;
    self.lblETA.accessibilityValue = self.rideDataModel.eta;
    
    //Setup Seconds and Colors btn Accept
    [self setupAcceptButtonStyle];

    //Setup Rider Image
    [self.imgRider sd_setImageWithURL:self.rideDataModel.rider.photoURL
                     placeholderImage:[UIImage imageNamed:@"rider_placeholder"]
                              options:SDWebImageHighPriority
                            completed:nil];
    
    //Setup Address
    self.lblPrimaryAddress.text = self.rideDataModel.startAddress.address;
    self.lblPrimaryAddress.accessibilityValue = self.rideDataModel.startAddress.address;
    
    //Setup Rider
    self.lblRiderUsername.text = self.rideDataModel.rider.firstName;
    self.lblRiderUsername.accessibilityValue = self.rideDataModel.rider.firstName;

    NSNumberFormatter *ratingFormatter = [NSNumberFormatter new];
    [ratingFormatter setMinimumFractionDigits:1];
    [ratingFormatter setMaximumFractionDigits:1];
    [ratingFormatter setRoundingMode:NSNumberFormatterRoundDown];
    
    NSString *riderRating = [ratingFormatter stringFromNumber:self.rideDataModel.rider.rating];
    self.lblRiderRating.text = riderRating;
    self.lblRiderRating.accessibilityValue = riderRating;

    //Setup Timer
    self.timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    
    if (self.tmpCarIcon) {
        self.carMarker = [GMSMarker markerWithPosition:self.tmpCarIcon.position];
        self.carMarker.rotation = self.tmpCarIcon.rotation;
        self.carMarker.icon = self.tmpCarIcon.icon;
        self.carMarker.groundAnchor = CGPointMake(0.5, 0.5);
        self.carMarker.map = self.googleMapView;
#ifdef AUTOMATION
        self.carMarker.accessibilityElementsHidden = NO;
        self.carMarker.accessibilityLabel = @"carRideRequest";
#endif
    }
    
    RARideAddressDataModel *pickupAddress = self.rideDataModel.startAddress;
    if (pickupAddress && self.carMarker) {
        [self showUserMarker];
        [self ShowAllMarkersWithStartLocation:self.carMarker.position
                       andDestinationLocation:pickupAddress.coordinate
                           withEdgeInsetsLeft:25.0
                                    withRight:25.0
                                      withTop:30.0
                                    andBottom:30.0];
    }
    
    self.btnDecline = [UIBarButtonItem RABarButtonWithTitle:[@"Decline" localized] target:self action:@selector(btnDeclineRequestTapped)];
    self.navigationItem.rightBarButtonItem = self.btnDecline;
    
    self.lblSecondsAvailable.text = @"";
    [self setupSeconds:self.event.remainingAcceptanceExpiration];
}

- (void)setupSeconds:(NSTimeInterval)leftSeconds {
    NSUInteger displaySeconds = leftSeconds > 0 ? leftSeconds : 0;
    self.lblSecondsAvailable.text = [NSString stringWithFormat:@"%ld", (unsigned long)displaySeconds];
}

#pragma mark - Style

- (void)configureLayoutIfNeeded {
    self.constraintTopLblETA.constant = (IS_IPHONE4 || IS_IPHONE4S) ? 8.0 : 17.0;
    
    if (IS_IPHONE4S || IS_IPHONE4 || IS_IPHONE5) {
        self.lblPrimaryAddress.font = [UIFont fontWithName:@"Montserrat-Light" size:15.0];
    }

    [self.view layoutIfNeeded];
}

- (void)setupAcceptButtonStyle {
    if ([self.rideDataModel containsDriverType:DriverTypeFemaleDriver]) {
        NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:[@"Accept \nFEMALE DRIVER" localized]];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setAlignment:NSTextAlignmentCenter];
        
        [attributedTitle addAttributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor],
                                          NSParagraphStyleAttributeName  : paragraphStyle }
                                 range:NSMakeRange(0, attributedTitle.string.length)];
        
        [attributedTitle addAttribute:NSFontAttributeName
                                value:[UIFont fontWithName:@"Montserrat-Light" size:36.0]
                                range:[[attributedTitle string] rangeOfString:[@"Accept" localized]]];
        
        [attributedTitle addAttribute:NSFontAttributeName
                                value:[UIFont fontWithName:@"Montserrat-Regular" size:14.0]
                                range:[[attributedTitle string] rangeOfString:[@"FEMALE DRIVER" localized]]];
        
        [self.btnAccept setAttributedTitle:attributedTitle forState:UIControlStateNormal];
        
        self.btnAccept.backgroundColor = kPinkAcceptColor;
        self.lblSecondsAvailable.backgroundColor = kPinkCountDownColor;
        
    } else if (self.rideDataModel.hasSurgeFactor) {
        self.btnAccept.backgroundColor = kBlueAcceptColor;
        self.lblSecondsAvailable.backgroundColor = kBlueCountDownColor;
    } else {
        self.btnAccept.backgroundColor = kGreenAcceptColor;
        self.lblSecondsAvailable.backgroundColor = kGreenCountDownColor;
    }
}

#pragma mark - Actions

- (void)btnDeclineRequestTapped {
    [self dismissRequestView];
    if (self.rideRequestDelegate) {
        [self.rideRequestDelegate didTapDeclineButtonForEvent:self.event];
    }
}

- (IBAction)acceptRide:(id)sender {
    [self dismissRequestView];
    if (self.rideRequestDelegate) {
        [self.rideRequestDelegate didTapAcceptButtonForEvent:self.event];
    }
}

#pragma mark - DriverStatusButtonVC protocol

- (void)driverStatusButtonHasBeenPressed:(DriverStatusButton *)sender {
    [self dismissRequestView];
    if (self.rideRequestDelegate) {
        [self.rideRequestDelegate didTapOnlineButtonForEvent:self.event];
    }    
}

#pragma mark - DriverState

- (void)updateDriverStateFromAcceptingToAvailableIfNeeded {
    // when driver taps accept call to open app, driverState is AcceptingRequest
    // need to reset back to AvailableDriverState
    if ([DriverManager shared].driverState == AcceptingRequest) {
        [DriverManager updateDriverState:AvailableDriverState];
    }
}

#pragma mark - Markers

- (void)showUserMarker {
    RARideAddressDataModel *pickupAddress = self.rideDataModel.startAddress;
    BOOL hasValidPickupLocation = pickupAddress && [LocationService isCoordinateValidForRide:pickupAddress.coordinate];
    if (hasValidPickupLocation) {
        self.userMarker = [GMSMarker markerWithPosition:pickupAddress.coordinate];
        self.userMarker.icon = [UIImage imageNamed:@"user-red-location-icon"];
        self.userMarker.map = hasValidPickupLocation ? self.googleMapView : nil;
        self.userMarker.zIndex = 5;
#ifdef AUTOMATION
        self.userMarker.accessibilityElementsHidden = NO;
        self.userMarker.accessibilityLabel = @"pickupRideRequest";
#endif
    }
}

#pragma mark - NSTimer Handler

- (void)invalidateTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)timerFired {
    NSTimeInterval leftTime = self.event.remainingAcceptanceExpiration;
    if (leftTime < 0) {
        [self invalidateTimer];
        [self dismissRequestView];
    
        if (self.rideRequestDelegate) {
            BFLog(@"Driver didn't accept RideRequest at time");
            [self.rideRequestDelegate didTimerFinishForEvent:self.event];
        }
       
    } else {
        [self setupSeconds:leftTime];
    }
}

#pragma mark - Helpers

- (void)ShowAllMarkersWithStartLocation:(CLLocationCoordinate2D)start andDestinationLocation:(CLLocationCoordinate2D)destination withEdgeInsetsLeft:(float)left withRight:(float)right withTop:(float)top andBottom:(float)bottom {
    if ([LocationService isCoordinateValidForRide:start] && [LocationService isCoordinateValidForRide:destination]) {
        GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:start coordinate:destination];
        [self.googleMapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withEdgeInsets:UIEdgeInsetsMake(top, left, bottom, right)]];
    }
}

#pragma mark - Show Method

- (void)showAnimated:(BOOL)animated {
    BFLog(@"Show RideRequestViewController");
    self.internalWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.internalWindow.rootViewController = [[UIViewController alloc] init];
    
    self.internalWindow.tintColor = [UIApplication sharedApplication].delegate.window.tintColor;
    self.internalWindow.windowLevel = UIWindowLevelAlert + kTopZIndex;
    
    [self.internalWindow makeKeyAndVisible];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self];
    navController.navigationBar.backgroundColor = [UIColor whiteColor];
    navController.modalPresentationStyle = UIModalPresentationFullScreen;
    self.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.internalWindow.rootViewController presentViewController:navController animated:animated completion:nil];
}

- (void)dismissRequestView {
    [self invalidateTimer];
    [self updateDriverStateFromAcceptingToAvailableIfNeeded];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)dismissRequestViewForRideRequestWithId:(NSString *)rideId {
    RARideDataModel *rideDataModel = self.event.isStackedRide ? self.event.nextRide : self.event.ride;
    if ([rideDataModel.modelID.stringValue isEqualToString:rideId]) {
        [self dismissRequestView];
    }
}

@end
