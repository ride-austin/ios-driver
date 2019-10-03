//
//  LocationViewController.m
//  RideAustin.com
//
//  Created by Tyson Bunch on 9/19/12.
//  Copyright (c) 2012 FuelMe, Inc. All rights reserved.
//

#import "LocationViewController.h"

#import <AudioToolbox/AudioSession.h>
#import <AudioToolbox/AudioToolbox.h>

#import "ADInputViewController.h"
#import "ActionViewDefines.h"
#import "AssetCityManager.h"
#import "CFFormViewController.h"
#import "ConfigurationManager.h"
#import "DirectConnectViewController.h"
#import "ErrorReporter+Extensions.h"
#import "GeocodeService.h"
#import "GoogleMapsManager+Facade.h"
#import "LocationService.h"
#import "LocationViewModel.h"
#import "MVPlaceSearchTextField.h"
#import "NSDate+Utils.h"
#import "NSObject+className.h"
#import "NSString+Ride.h"
#import "NSString+Utils.h"
#import "NavigationAppUtil.h"
#import "QueueEvent.h"
#import "RAActiveDriverPolling.h"
#import "RAAlertManager+Extension.h"
#import "RACallKitManager.h"
#import "RACarCategoryDataModel+Collections.h"
#import "RAEventPolling.h"
#import "RAEventsAPI.h"
#import "RAFloatingMenuDataSource.h"
#import "RANextRideViewController.h"
#import "RAPollingManager.h"
#import "RARatingManager.h"
#import "RARideAPI.h"
#import "RARideCacheManager.h"
#import "RASideMenu.h"
#import "RASimpleAlertView.h"
#import "RAUpgradePopup.h"
#import "RatingViewController.h"
#import "RideDriverConstants.h"
#import "RideDriver-Swift.h"
#import "RideRate.h"
#import "RideRequestViewController.h"
#import "SettingsViewController.h"
#import "TermAndConditionViewController.h"
#import "UITextField+Valid.h"
#import "Util.h"
#import "VersionManager.h"
#import "WeeklyEarningsViewController.h"

#import "KLCPopup.h"
#import <GoogleMaps/GoogleMaps.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <UIActivityIndicator_for_SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>

static CGFloat const kMinCommentsHeight = 70.0;
static CGFloat const kOneLineHeight = 17.0;
static NSString *const FAChevronDownIcon = @"\uf078";

@interface LocationViewController ()<GMSMapViewDelegate, RideRequestDelegate, DriverStateDelegate, ActionViewDelegate, RAFloatingMenuDelegate>

#pragma mark - IBOutlets

@property (weak, nonatomic) IBOutlet UIBarButtonItem* btMenu;
@property (weak, nonatomic) IBOutlet UIButton *btnRightBarButton;

//Polling
@property (strong, nonatomic) id<RAPollingManager> eventPolling;
@property (strong, nonatomic) id<RAPollingManager> activeDriversPolling;

//LocationViewModel
@property (strong, nonatomic) LocationViewModel *locationViewModel;

//Rating
@property (strong, nonatomic) RatingViewController *ratingViewController;
@property (strong, nonatomic) KLCPopup * ratingPopUp;

//Next Ride
@property (nonatomic) RANextRideViewController *nextRideViewController;

//cancellation prompt
@property (nonatomic) UIViewController *cancellationPromptViewController;

//Ride Address View
@property (weak, nonatomic) IBOutlet UIView *riderAddressView;
@property (weak, nonatomic) IBOutlet UITextField *riderAddressView_pickup;
@property (weak, nonatomic) IBOutlet MVPlaceSearchTextField *riderAddressView_dropoff;
@property (weak, nonatomic) IBOutlet UIButton *btnNavigateTrip;
@property (weak, nonatomic) IBOutlet UIButton *btnCancelTrip;
@property (weak, nonatomic) IBOutlet UIButton *btnNextRide;

//Rider Comment View
@property (nonatomic, getter=isRiderCommentViewAnimating) BOOL riderCommentViewAnimating;
@property (nonatomic, getter=isRiderCommentViewExpanded) BOOL riderCommentViewExpanded;
@property (weak, nonatomic) IBOutlet UIView *commentView;
@property (weak, nonatomic) IBOutlet UILabel* commentLabel;
@property (weak, nonatomic) IBOutlet UIButton* commentToggleButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentHeightConstraint;

//Floating Menu
@property (weak, nonatomic) IBOutlet UIView *vFloatingOverlay;
@property (weak, nonatomic) IBOutlet LiquidFloatingActionButton *btnFloatingMenu;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBottomFloatingMenu;
@property (strong, nonatomic) RAFloatingMenuDataSource *floatingMenuDataSourceAndDelegate;

//Upgrade Popup
@property (strong, nonatomic) RAUpgradePopup *upgradePopup;

//Side Menu
@property (strong, nonatomic) RASideMenu *sideMenu;

//Map markers and polyline
@property (strong, nonatomic) GoogleMapsManager *googleMapsManager;

/**
 *  @brief keep a pointer of alert so we can hide it when a ride is cancelled
 */
@property (strong, nonatomic) UIAlertController *startTripReminderAlert;

@property (nonatomic) UIView *offlineMessageView;
@property (nonatomic) NSTimer *offlineAnimTimer;

@property (nonatomic) SurgeAreaManager *surgeAreaManager;

@property (nonatomic) BOOL isLocalNotificationDisplayed;

/**
 * @brief Indicate if the map should auto update location / zoom
 */
@property (nonatomic) BOOL isAllowAutomaticallyMapUpdate;

/**
 * @brief RideRequestViewController used to show request
 */
@property (nonatomic, weak) RideRequestViewController *rideRequestViewController;

/**
 * @brief Used for timer to remove rider location (blue dot) from map if no location is received after configured time.
 */
@property (nonatomic) NSTimeInterval riderLocationExpirationTime;
@property (nonatomic) NSTimer *riderLocationExpirationTimer;

@property (nonatomic, assign) BOOL viewAlreadyShown;

- (RARideDataModel *)rideDataModel;

@end

@interface LocationViewController (RiderLocationExpiration)

- (void)restartRiderLocationTimer;
- (void)startRiderLocationTimer;
- (void)riderLocationTimerExecution;
- (void)stopRiderLocationTimer;
- (void)riderLocationHasExpired;

@end

@interface LocationViewController (LocationUpdate) <LocationUpdateDelegate>

- (void)configureLocationService;

@end

@interface LocationViewController (UnratedRide)

- (void)checkUnratedRides;

@end

@interface LocationViewController (CancellationFeedback)

- (UIViewController *)showCancellationFeedbackScreenForRide:(RARideDataModel *)ride;
- (UIViewController *)showCancellationConfirmationForRide:(RARideDataModel *)ride;

@end

@interface LocationViewController (DriverState)

- (void)updateDriverBtnWithState:(DriverState)driverState andRideDataModel:(RARideDataModel *)rideDataModel;

@end

@interface LocationViewController (ActiveDrivers) <RAActiveDriverPollingDelegate>

@end

@interface LocationViewController (RideCacheDelegate)<RARideCacheManagerDelegate>

@end

@interface LocationViewController (FloatingMenu)

- (void)closeFloatingMenuIfNeeded;
- (void)updateFloatingMenuWithDriverState:(DriverState)driverState;

@end

@interface LocationViewController (UpgradePopup) <RAUpgradePopupDelegate>

@end

@interface LocationViewController (EventPollingHandler) <RAEventPollingDelegate>

@end

@interface LocationViewController (DriveUsageActionsTemporary)

- (void)didTapOnlineButton:(UIButton *)sender;
- (void)didTapOfflineButton:(UIButton *)sender;
- (void)didTapArrived:(UIButton *)sender;
- (void)didTapStartTrip:(UIButton *)sender;
- (void)didTapEndTrip:(UIButton *)sender;
- (void)attemptToAcceptRideForRideRequestEvent:(id<RARideRequestProtocol>)event;

@end

@implementation LocationViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[RARideCacheManager sharedManager] setDelegate:self];
    
    //Configure Services
    self.locationViewModel = [[LocationViewModel alloc] init];
    [self configureLocationService];
    self.actionView.delegate = self;
    
    //Initialize Properties
    self.isLocalNotificationDisplayed = NO;
    
    //Configure UI Elements
    self.sideMenu = [RASideMenu configureWithPresenter:self];
    
    //Configure GoogleMaps and Car
    [self configureGoogleMaps];
    
    //RA-339 ~ Meamwhile disable ability to driver change destination
    [self.riderAddressView_dropoff setEnabled:NO];
    
    //Surge pricing
    self.surgeAreaManager.mapView = self.googleMapView;
    
    //Configure NavigationBar
    [self configureNavigatonBar];
    
    //Add Observers
    [self addObservers];
    
    //Accessibility
    [self configureAccessibility];
    
    //Setup Ride Comments
    [self.commentToggleButton setTitle:FAChevronDownIcon forState:UIControlStateNormal];
    
    //Floating Menu
    self.floatingMenuDataSourceAndDelegate = [[RAFloatingMenuDataSource alloc] initWithDelegate:self];
    self.btnFloatingMenu.dataSource = self.floatingMenuDataSourceAndDelegate;
    self.btnFloatingMenu.delegate = self.floatingMenuDataSourceAndDelegate;
    self.btnFloatingMenu.accessibilityIdentifier = @"FloatingActionButton";
    self.btnFloatingMenu.isAccessibilityElement = NO;
    
    //Configure NavigationBar content
    [DriverManager shared].delegate = self;
    [self updateUIForDriverState:[DriverManager shared].driverState withRide:[DriverManager shared].rideDataModel];
    
    //Configure Polling
    self.eventPolling = [[RAEventPolling alloc] initWithDelegate:self];
    [self.eventPolling start];
    
    self.activeDriversPolling = [[RAActiveDriverPolling alloc] initWithDelegate:self];
}

- (void)configureNavigatonBar {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = self.btMenu;
    CGFloat btnContactWidth = [UIScreen mainScreen].bounds.size.width <= 320 ? 68.0 : 80.0;
    self.btnRightBarButton.frame = CGRectMake(0, 0, btnContactWidth, 28.0);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.isAllowAutomaticallyMapUpdate = YES;
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    self.navigationController.navigationBar.accessibilityIdentifier = @"LocationViewController";
    
    // Make sure location is started
    [[LocationService sharedService] start];
    
    if (![PersistenceManager hasCallSetting]) {
        [PersistenceManager saveCallSetting:AcceptRequest];
    }
    
    [RARatingManager sendRideRatedCacheToServer];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.viewAlreadyShown) {
        self.viewAlreadyShown = YES;
        [self showNewTermsAndConditionIfNeeded];
    }
    
    if (![[DriverManager shared] isDriverOnActiveRide] && [PersistenceManager hasUnratedRide]) {
        [self checkUnratedRides];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if ([self isBeingDismissed] || [self isMovingFromParentViewController]) {
        [self.eventPolling stop];
        [self.ratingPopUp dismiss:NO];
    }
}

- (void)dealloc {
    [self.activeDriversPolling stop];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - DriverStateDelegate

- (DriverState)driverState {
    return [DriverManager shared].driverState;
}

- (RARideDataModel *)rideDataModel {
    return [DriverManager shared].rideDataModel;
}

- (void)driverManagerDidUpdateRide:(RARideDataModel *)rideDataModel {
    [self.locationViewModel setRideDataModel:rideDataModel];
    [self setRiderComment:rideDataModel.comment];
    if (rideDataModel) {
        [self updateStartAddressValue];
        [self updateEndAddressValue];
    } else {
        [self.googleMapsManager clearRideMarkers];
    }
}

- (void)driverManagerDidUpdateStackedRide:(RARideDataModel *)nextRide {
    [self updateUIForDriverState:[self driverState] withRide:self.rideDataModel];
}

- (void)driverManagerDidUpdateDriverState:(DriverState)driverState fromPreviousDriverState:(DriverState)previousDriverState withRide:(RARideDataModel *)rideDataModel {
    [self updateUIForDriverState:driverState withRide:rideDataModel];
    if ([ConfigurationManager shared].global.shouldShowOnlinePopup && previousDriverState == OfflineDriverState && driverState == AvailableDriverState) {
        [RAAlertManager showOnlineDriverDescription];
    }
}

- (void)updateUIForDriverState:(DriverState)driverState withRide:(RARideDataModel *)rideDataModel {
    [self driverManagerDidUpdateRide:rideDataModel];
    [self updateDriverBtnWithState:driverState andRideDataModel:rideDataModel];
    [self updateRightBarBtnBasedOnDriverState];
    [self updateServicesBasedOnDriverState:driverState];
    [self hideRiderMarkerForState:driverState];
    [self autoSwipeManager];
    [self updateFloatingMenuWithDriverState:driverState];
    [self updateZoomAndRouteForState:driverState];
    [self resetRemindersBasedOnDriverState:driverState];
    [self showNextRideMarkerIfNeeded];
}

- (void)updateZoomAndRouteForState:(DriverState)driverState {
    switch (driverState) {
        case GoingToPickUpDriverState:
            [self showRouteAndMarkersForGoingToPickUpDriverState];
            break;
            
        case ArrivingToPickUpDriverState:
        case OnTripDriverState:
            [self showRouteAndMarkersWhenArrivedAndOnTrip];
            break;
            
        case InvalidDriverState:
        case OfflineDriverState:
        case AcceptingRequest:
            [self.googleMapsManager clearRideMarkers];
            break;
        case AvailableDriverState:
            [self.googleMapsManager clearRideMarkers];
            [self findMyLocation];
            break;
    }
}

- (void)resetRemindersBasedOnDriverState:(DriverState)driverState {
    switch (driverState) {
        case AvailableDriverState:
            [PersistenceManager enableShowStartTripReminderNotification:YES];
            break;
            
        default:
            break;
    }
}

#pragma mark - RideDataModel

- (void)updateStartAddressValue {
    if (self.rideDataModel.startAddress.address) {
        [self setPickupTextField:self.rideDataModel.startAddress.primaryAddress];
        return;
    }
    
    CLLocation *fromLoc = self.rideDataModel.startAddress.location;
    [[GeocodeService sharedInstance] reverseGeo:fromLoc completeBlock:^(NSString *zip, NSString *address, NSString *fullAddress, NSString *city, NSString *state, NSString *county, NSString *neighborhood, NSError *error) {
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setPickupTextField:address];
            });
        }
    }];
}

- (void)updateEndAddressValue {
    self.riderAddressView_dropoff.text = @"";
    if (self.rideDataModel.endAddress && [LocationService isCoordinateValidForRide:self.rideDataModel.endAddress.coordinate]) {
        if (self.rideDataModel.endAddress.address) {
            self.riderAddressView_dropoff.text = [self.rideDataModel.endAddress.address stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            return;
        }
        
        CLLocation *toLoc = self.rideDataModel.endAddress.location;
        [[GeocodeService sharedInstance] reverseGeo:toLoc completeBlock:^(NSString *zip, NSString *address, NSString *fullAddress, NSString *city, NSString *state, NSString *county, NSString *neighborhood, NSError *error) {
            if (!error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.riderAddressView_dropoff.text = address;
                });
            }
        }];
    }
}

- (void)showRouteAndMarkersForGoingToPickUpDriverState {
    __weak __typeof__(self) weakself = self;
    [self drawLocationMarkers];
    [self drawRouteForState:self.driverState withBlock:^(CLLocationCoordinate2D startCoordinate, CLLocationCoordinate2D endCoordinate) {
        [weakself.googleMapsManager attempToDrawRouteFrom:startCoordinate to:endCoordinate completion:^{
            [weakself updateMapZoomByRidingState];
        }];
    }];
}

- (void)showRouteAndMarkersWhenArrivedAndOnTrip {
    __weak __typeof__(self) weakself = self;
    [self drawLocationMarkers];
    [self.googleMapsManager removeRideRoute];
    if ([self.locationViewModel canProceedToCreateRoute]) {
        [self drawRouteForState:self.driverState withBlock:^(CLLocationCoordinate2D startCoordinate, CLLocationCoordinate2D endCoordinate) {
            [weakself.googleMapsManager createRouteFrom:startCoordinate to:endCoordinate completion:nil];
            [weakself updateMapZoomByRidingState];
        }];
    } else {
        [self.googleMapsManager animateToLocation:[LocationService sharedService].myLocation.coordinate];
    }
}

- (void)showNextRideMarkerIfNeeded {
    switch (self.driverState) {
        case OnTripDriverState:
            if (self.rideDataModel.nextRide && [self.rideDataModel.nextRide.startAddress isValid]) {
                [self.googleMapsManager createOrUpdateNextTripMarkerWithCoordinate:self.rideDataModel.nextRide.startAddress.coordinate];
            } else {
                [self.googleMapsManager removeNextTripMarker];
            }
            break;
        default:
            [self.googleMapsManager removeNextTripMarker];
            break;
    }
}

#pragma mark - Action View Delegate

- (void)actionViewDidTap:(UIButton *)sender withAction:(ActionType)type {
    __weak LocationViewController *weakSelf = self;
    switch (type) {
        case Arrived:
            [self didTapArrived:sender];
            break;
        case Begin: {
            [RAAlertManager showStartTripConfirmationWithAcceptBlock:^{
                [weakSelf didTapStartTrip:sender];
            }];
            break;
        }
        case End: {
            [RAAlertManager showEndTripConfirmationWithAcceptBlock:^{
                [weakSelf didTapEndTrip:sender];
            }];
            break;
        }
        case Idle:
            //clear and hide
            break;
            
        default:
            break;
    }
}

#pragma mark - Services

- (void)updateServicesBasedOnDriverState:(DriverState)driverState {
    switch (driverState) {
        case InvalidDriverState:
        case OfflineDriverState:
        case AvailableDriverState:
            [self setupServicesNotInRide];
            break;
        case AcceptingRequest:
        case GoingToPickUpDriverState:
        case ArrivingToPickUpDriverState:
        case OnTripDriverState:
            [self setupServicesWhileInRide];
            break;
    }
}

- (void)setupServicesWhileInRide {
    [self.activeDriversPolling stop];
    [self.googleMapsManager removeAllNearbyDrivers];
    [self.surgeAreaManager hideCurrentSurgeAreas];
}

- (void)setupServicesNotInRide {
    [self.activeDriversPolling start];
    [self.surgeAreaManager showCurrentSurgeAreas];
}

#pragma mark - Action Buttons

- (IBAction)btnCancelTripTapped:(UIButton *)sender {
    BFLog(@"Driver tap cancel for ride with Id : %@",self.rideDataModel.modelID);
    if (YES || [ConfigurationManager shared].global.cancellationFeedback.enabled) {
        self.cancellationPromptViewController = [self showCancellationFeedbackScreenForRide:self.rideDataModel];
    } else {
        self.cancellationPromptViewController = [self showCancellationConfirmationForRide:self.rideDataModel];
    }
}

- (IBAction)btnNextRideTapped:(id)sender {
    RARideDataModel *nextRide = self.rideDataModel.nextRide;
    if (nextRide && !self.nextRideViewController) {
        self.nextRideViewController = (RANextRideViewController *)[self createViewControllerFromStoryboard:@"Overlays" withIdentifier:NSStringFromClass([RANextRideViewController class])];
        self.nextRideViewController.nextRide = nextRide;
        
        __weak LocationViewController *weakSelf = self;
        self.nextRideViewController.dismissCompletion = ^{
            weakSelf.nextRideViewController = nil;
        };
        
        [self.nextRideViewController show];
    } else {
        [self.btnNextRide setHidden:YES];
    }
}

#pragma mark - Terms & Condition

- (void)askConfirmationToReadNewTermsAndConditionsWithMessage:(NSString*)message {
    RAAlertOption *option = [RAAlertOption optionWithState:StateActive];
    [option addAction:[RAAlertAction actionWithTitle:[@"CANCEL" localized] style:UIAlertActionStyleCancel handler:nil]];
    [option addAction:[RAAlertAction actionWithTitle:[@"READ" localized] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nullable action) {
        [self showNewTermsAndConditionIfNeeded];
    }]];
    [RAAlertManager showAlertWithTitle:[ConfigurationManager getRegisteredCity].appName message:message options:option];
}

- (void)showNewTermsAndConditionIfNeeded {
    BOOL agreedToLegalTerms = [RASessionManager shared].currentSession.driver.agreedToLegalTerms;
    if (agreedToLegalTerms == NO && [DriverManager shared].isDriverOnActiveRide == NO) {
        [self performSegueWithIdentifier:[LocationViewController segueTo:[TermAndConditionViewController class]] sender:nil];
    }
}

#pragma mark - SurgeAreaManager

- (void)initializeSurgeAreaManagerWithCompletion:(void(^)(void))completion {
    [self.surgeAreaManager getSurgeAreasWithCompletion:completion];
}

- (SurgeAreaManager *)surgeAreaManager {
    if (!_surgeAreaManager) {
        _surgeAreaManager = [SurgeAreaManager new];
    }
    return _surgeAreaManager;
}

#pragma mark - Configure GoogleMapsView

- (void)configureGoogleMaps {
    self.googleMapsManager = [[GoogleMapsManager alloc] initWithMap:self.googleMapView];
    
    CLLocation *currentLocation = [LocationService sharedService].myLocation;
    [self.googleMapsManager defaultMapConfigurationWithDelegate:self andLocation:currentLocation];
    [self.googleMapsManager createCarMarkerWithCoordinate:currentLocation.coordinate];
}

#pragma mark- Accessibilities

- (void)configureAccessibility {
    self.navigationController.navigationBar.accessibilityIdentifier = @"LocationViewControllerNavigationBar";
    self.btMenu.accessibilityIdentifier = @"show menu";
    
    self.riderAddressView.accessibilityLabel = @"riderAddressView";
    self.riderAddressView_pickup.accessibilityLabel = @"riderAddressView_pickup";
    self.riderAddressView_dropoff.accessibilityLabel = @"riderAddressView_dropoff";
    
    self.googleMapView.accessibilityElementsHidden = NO;
    self.googleMapView.accessibilityLabel = @"GoogleMap";
}

- (void)addObservers {
    __weak LocationViewController *weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:kNetworkReachabilityStatusChanged object:nil queue:[NSOperationQueue mainQueue] usingBlock:^ (NSNotification *notification) {
        NSNumber *statusNumber = (NSNumber *)notification.object;
        AFRKNetworkReachabilityStatus status = [statusNumber intValue];
        [weakSelf handleReachabilityStatusChange:status];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kAcceptRideRequestNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^ (NSNotification *notification) {
        id<RARideRequestProtocol> event = [notification.userInfo objectForKey:@"event"];
        [weakSelf attemptToAcceptRideForRideRequestEvent:event];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kDidSignoutNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [NSObject cancelPreviousPerformRequestsWithTarget:weakSelf selector:@selector(enableAutomaticallyMapUpdate) object:nil];
        [weakSelf.activeDriversPolling stop];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kUnratedRideAddedFromRideCache object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [weakSelf checkUnratedRides];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kUserCarTypesHasBeenChangedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [weakSelf.surgeAreaManager showCurrentSurgeAreas];
    }];
}

- (IBAction)riderAddressViewTapped:(UITapGestureRecognizer *)sender {
    CGPoint touchLocation = [sender locationInView:sender.view];
    CGRect addressPickupFrame = self.riderAddressView_pickup.frame;
    CGRect addressDestinationFrame = self.riderAddressView_dropoff.frame;
    
    if (![self.riderAddressView_pickup isHidden] && CGRectContainsPoint(addressPickupFrame, touchLocation) && ![self.riderAddressView_pickup isEmpty]) {
        RASimpleAlertView *simpleAlert = [RASimpleAlertView simpleAlertViewWithTitle:[@"Address Pickup" localized] andMessage:self.riderAddressView_pickup.text];
        [simpleAlert show];
    } else if (![self.riderAddressView_dropoff isHidden] && CGRectContainsPoint(addressDestinationFrame, touchLocation) && ![self.riderAddressView_dropoff isEmpty]) {
        RASimpleAlertView *simpleAlert = [RASimpleAlertView simpleAlertViewWithTitle:[@"Address Destination" localized] andMessage:self.riderAddressView_dropoff.text];
        [simpleAlert show];
    }
}

#pragma mark - Rider Comment view

- (CGFloat)heightForRiderComment {
    CGSize constraint = CGSizeMake(self.commentLabel.bounds.size.width, CGFLOAT_MAX);
    NSMutableParagraphStyle *paragraph = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraph.lineBreakMode = self.commentLabel.lineBreakMode;
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                self.commentLabel.font, NSFontAttributeName,
                                paragraph, NSParagraphStyleAttributeName,
                                nil];
    return ceil([self.commentLabel.text boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:attributes context:nil].size.height);
}

- (void)commentToggleButtonPressed:(UIButton *)sender {
    if (![self isRiderCommentViewAnimating]) {
        self.riderCommentViewAnimating = YES;
        
        self.commentLabel.lineBreakMode = self.isRiderCommentViewExpanded ? NSLineBreakByTruncatingTail : NSLineBreakByWordWrapping;
        self.commentLabel.numberOfLines = self.isRiderCommentViewExpanded ? 1 : 0;
        CGFloat height = self.isRiderCommentViewExpanded ? kMinCommentsHeight + kOneLineHeight : kMinCommentsHeight + [self heightForRiderComment];

        self.commentHeightConstraint.constant = height;
        [UIView animateWithDuration:0.25
                         animations:^{
                             self.commentToggleButton.transform = self.isRiderCommentViewExpanded ? CGAffineTransformIdentity : CGAffineTransformMakeRotation(M_PI);
                             [self.view layoutIfNeeded];
                         }
                         completion:^(BOOL finished) {
                             self.riderCommentViewExpanded = ![self isRiderCommentViewExpanded];
                             self.riderCommentViewAnimating = NO;
                         }
         ];
    }
}

- (BOOL)canShowRiderComment {
    DriverState driverState = [[DriverManager shared] driverState];
    switch (driverState) {
        case GoingToPickUpDriverState:
        case ArrivingToPickUpDriverState:
            return YES;
        case OnTripDriverState:
        case AcceptingRequest:
        case InvalidDriverState:
        case OfflineDriverState:
        case AvailableDriverState:
            return NO;
    }
}

- (void)showRiderCommentAnimated:(BOOL)animated {
    if ([self canShowRiderComment]) {
        if (animated && !self.riderCommentViewAnimating) {
            self.riderCommentViewAnimating = YES;
            
            self.commentHeightConstraint.constant = kMinCommentsHeight + kOneLineHeight;
            [self.commentToggleButton setTitle:FAChevronDownIcon forState:UIControlStateNormal];
            self.riderCommentViewExpanded = NO;
            self.commentLabel.numberOfLines = 1;
            self.commentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            
            [UIView animateWithDuration:0.25
                             animations:^{
                                 self.commentToggleButton.transform = CGAffineTransformIdentity;
                                 [self.view layoutIfNeeded];
                             }
                             completion:^(BOOL finished) {
                                 self.riderCommentViewAnimating = NO;
                             }
             ];
            
        } else {
            [self.view layoutIfNeeded];
        }
    }
}

- (void)hideRiderCommentAnimated:(BOOL)animated {
    self.commentHeightConstraint.constant = 0;
    if (animated && !self.riderCommentViewAnimating) {
        self.riderCommentViewAnimating = YES;

        [UIView animateWithDuration:0.25
                         animations:^{
                             [self.view layoutIfNeeded];
                         }
                         completion:^(BOOL finished) {
                             self.riderCommentViewAnimating = NO;
                         }
         ];

    } else {
        [self.view layoutIfNeeded];
    }
}

- (void)showOrHideRiderCommentAnimated:(BOOL)animated {
    if (IS_EMPTY(self.commentLabel.text)) {
        [self hideRiderCommentAnimated:animated];
    } else {
        [self showRiderCommentAnimated:animated];
    }
}

- (void)setRiderComment:(NSString*)riderComment {
    self.commentLabel.text = riderComment;
    self.commentLabel.accessibilityValue = riderComment;
    
    self.commentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    NSUInteger lines = [self heightForRiderComment] / kOneLineHeight;
    self.commentLabel.lineBreakMode = self.isRiderCommentViewExpanded ? NSLineBreakByWordWrapping : NSLineBreakByTruncatingTail;
    [self.commentToggleButton setHidden:lines<=1];
    [self showOrHideRiderCommentAnimated:YES];
}

- (void)handleReachabilityStatusChange:(AFRKNetworkReachabilityStatus)status {
    __weak LocationViewController *weakSelf = self;
    
    switch (status) {
        case AFRKNetworkReachabilityStatusNotReachable: {
            [weakSelf.eventPolling stop];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf showOfflineMessageViewWithMessage:[@"No internet connection." localized]];
            });
            break;
        }
        case AFRKNetworkReachabilityStatusReachableViaWiFi:
        case AFRKNetworkReachabilityStatusReachableViaWWAN: {
            if ([RARideCacheManager sharedManager].hasCacheToFlush == NO) {
                [[DriverManager shared] synchronizeStateWithCompletion:^(DriverState state, RARideDataModel * _Nullable ride) {
                    [weakSelf.eventPolling start];
                }];
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf closeOffileMessageView:nil];
            });
            
            [RARatingManager sendRideRatedCacheToServer];
            break;
        }
        case AFRKNetworkReachabilityStatusUnknown: {
            break;
        }
    }
}

#pragma mark - Floating Menu Protocol

- (void)showUpgradePopupWithRideRequestUpgrade:(RideRequestUpgrade*)rideRequestUpgrade {
    if (self.upgradePopup) {
        [self.upgradePopup updateToStatus:rideRequestUpgrade.status];
    } else {
        self.upgradePopup = [RAUpgradePopup upgradePopupWithTargetName:rideRequestUpgrade.targetName status:rideRequestUpgrade.status andDelegate:self];
        [self.upgradePopup show];
    }
}

#pragma mark - DriverStatusVC protocol

- (void)driverStatusButtonHasBeenPressed:(DriverStatusButton *)sender {
    switch (sender.status) {
        case DABSSync:
            [[RARideCacheManager sharedManager] flushAllRideCacheWithCompletion:nil];
            break;
            
        case DABSOnline:
            [self didTapOnlineButton:sender];
            break;
        case DABSOffline:
            [self didTapOfflineButton:sender];
            break;
        case DABSHidden:
        case DABSLoading:
        case DABSDisabled:
            break;
    }
}

- (IBAction)btnMenuPressed:(id)sender {
    [self.sideMenu show];
}

- (void)showOfflineMessageViewWithMessage:(NSString *)message {
    if (self.offlineMessageView == nil) {
        self.offlineMessageView = [[UIView alloc] initWithFrame:CGRectMake(0, -40, CGRectGetWidth(self.view.bounds), 30)];
        self.offlineMessageView.alpha = 0.7f;
        self.offlineMessageView.clipsToBounds = YES;
        
        UIColor *backgroundColor = [UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f];
        self.offlineMessageView.backgroundColor = backgroundColor;
        
        CGRect msgLableFrame = CGRectMake(5, 4, 45, CGRectGetHeight(self.offlineMessageView.bounds)-8);
        UILabel *msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(msgLableFrame.origin.x+msgLableFrame.size.width+2, 0, CGRectGetWidth(self.offlineMessageView.bounds) - msgLableFrame.size.width-40, CGRectGetHeight(self.offlineMessageView.bounds))];
        msgLabel.font = [UIFont systemFontOfSize:13.0f];
        msgLabel.textAlignment = NSTextAlignmentCenter;
        msgLabel.textColor = [UIColor whiteColor];
        msgLabel.userInteractionEnabled = YES;
        msgLabel.text = message;
        [self.offlineMessageView addSubview:msgLabel];
        
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton setFrame:CGRectMake(msgLabel.frame.size.width+msgLabel.frame.origin.x-4, 0, 40, CGRectGetHeight(self.offlineMessageView.bounds))];
        [closeButton setTitle:@"X" forState:UIControlStateNormal];
        [closeButton.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(closeOffileMessageView:) forControlEvents:UIControlEventTouchUpInside];
        [self.offlineMessageView addSubview:closeButton];
        
        [self.view addSubview:self.offlineMessageView];
        
        [self.view setNeedsLayout];
        
        [UIView animateWithDuration:0.5 delay:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^ {
                             self.offlineMessageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 30);
                         }
                         completion:^(BOOL finished) {
                             [self.offlineAnimTimer invalidate];
                             self.offlineAnimTimer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(internetConnectionMonitorTimer:) userInfo:nil repeats:YES];
                         }];
        
        [UIView animateWithDuration:0.5
                         animations:^{
                             [self.view layoutIfNeeded]; // Called on parent view
                         }];
    }
}

- (void)closeOffileMessageView:(id)sender {
    if (self.offlineMessageView!=nil) {
        [self.view setNeedsLayout];
        
        [UIView animateWithDuration:0.5 delay:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^ {
                             self.offlineMessageView.frame = CGRectMake(0, -40, CGRectGetWidth(self.view.bounds), 30);
                         }
                         completion:^(BOOL finished) {
                             NSLog(@"Done");
                             [self.offlineMessageView removeFromSuperview];
                             self.offlineMessageView = nil;
                             
                             [self.offlineAnimTimer invalidate];
                             self.offlineAnimTimer = nil;
                         }];
        
        [UIView animateWithDuration:0.5
                         animations:^{
                             [self.view layoutIfNeeded]; // Called on parent view
                         }];
    }
}

- (void)internetConnectionMonitorTimer:(NSTimer *)timer {
    if ([[NetworkManager sharedInstance] isNetworkReachable]) {
        [self closeOffileMessageView:nil];
    }
}

#pragma mark - RIGHT BAR BUTTONS

- (void)updateRightBarBtnBasedOnDriverState {
    if (self.driverState == OnTripDriverState && self.rideDataModel.nextRide != nil) {
        [self.btnRightBarButton setHidden:YES];
    } else {
        [self setupRightBarBtn];
    }
}

- (void)setupRightBarBtn {
    [self.btnRightBarButton setHidden:NO];
    //Set Title
    NSString *btnTitle = [DriverManager shared].isDriverOnActiveRide ? [@"Contact" localized] : [@"Support" localized];
    [self.btnRightBarButton setTitle:btnTitle forState:UIControlStateNormal];
    
    //Clean Previous Targets
    [self.btnRightBarButton removeTarget:self action:@selector(btContactRiderTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.btnRightBarButton removeTarget:self action:@selector(btContactSupport) forControlEvents:UIControlEventTouchUpInside];
    
    //Add new Target
    SEL action = [DriverManager shared].isDriverOnActiveRide ? @selector(btContactRiderTapped) : @selector(btContactSupport);
    [self.btnRightBarButton addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
}

- (void)btContactRiderTapped {
    NSString *message = [NSString stringWithFormat:[@"How do you want to contact %@?" localized], self.rideDataModel.rider.firstName];
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@""
                                                                message:message
                                                         preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *call = [UIAlertAction actionWithTitle:[@"CALL" localized]
                                                   style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction * _Nonnull action) {
        [Util startContactCallWithPhoneNumber:[Util maskNumberIfNeeded:self.rideDataModel.rider.phoneNumber]];
    }];
    
    
    UIAlertAction *sms = [UIAlertAction actionWithTitle:[@"SMS" localized]
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
        [Util startContactSMSWithPhoneNumber:[Util maskNumberIfNeeded:self.rideDataModel.rider.phoneNumber]];
    }];
    
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:[@"CANCEL" localized]
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    
    [ac addAction:call];
    [ac addAction:sms];
    [ac addAction:cancel];
    
    ac.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;
    [self.navigationController presentViewController:ac animated:YES completion:nil];
}

- (void)btContactSupport {
    [self showMessageViewWithRideID:nil];
}

#pragma mark- AUTO SWIPE MANAGER

- (void)autoSwipeManager {
    switch (self.driverState) {
        case GoingToPickUpDriverState:
            [[LocationService sharedService] cancelLocationChangedObservers];
            [self autoArriveIfDriverIsNearPickupLocation];
            break;
        case ArrivingToPickUpDriverState:
            [[LocationService sharedService] cancelProximityObservers];
            [self checkIfDriverHasStartedTripWithoutSlidingButton];
            break;
        case OnTripDriverState:
            [[LocationService sharedService] cancelLocationChangedObservers];
            [self autoEndIfDriverIsNearDestination];
            break;
        default:
            [[LocationService sharedService] cancelLocationChangedObservers];
            [[LocationService sharedService] cancelProximityObservers];
            break;
    }
}

- (void)autoArriveIfDriverIsNearPickupLocation {
    __weak LocationViewController *weakself = self;
    CLLocation *pickupLocation = self.rideDataModel.startAddress.location;
    if (pickupLocation.isValid) {
        [[LocationService sharedService] observeIfProximity:10 to:pickupLocation reachedWithCompletion:^{
            if (weakself.driverState == GoingToPickUpDriverState) {
                [weakself didTapArrived:weakself.actionView.btnTrip];
            }
        }];
    }
}

- (void)checkIfDriverHasStartedTripWithoutSlidingButton {
    
    if (![PersistenceManager shouldShowStartTripReminderNotification] || [self driverState] != ArrivingToPickUpDriverState) {
        return;
    }
    
    const CGFloat kMetersForLocationChangedNotification = 50;
    __weak LocationViewController *weakSelf = self;
    [[LocationService sharedService] notifyIfLocationChangesIn:kMetersForLocationChangedNotification withCompletion:^(CLLocationCoordinate2D newLocation) {
        if (weakSelf.driverState != OnTripDriverState) {
            if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
                RAAlertOption *options = [[RAAlertOption alloc] initWithTitle:nil withState:StateActive andShownOption:Overlap];
                
                [options addAction:[RAAlertAction actionWithTitle:[@"Start trip" localized] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nullable action) {
                    [weakSelf didStartTripFromAlerts];
                    weakSelf.startTripReminderAlert = nil;
                }]];
                
                [options addAction:[RAAlertAction actionWithTitle:[@"Don't show again (on this trip)" localized] style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nullable action) {
                    [PersistenceManager enableShowStartTripReminderNotification:NO];
                    weakSelf.startTripReminderAlert = nil;
                }]];
                
                [options addAction:[RAAlertAction actionWithTitle:[@"Cancel" localized] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nullable action) {
                    [weakSelf checkIfDriverHasStartedTripWithoutSlidingButton];
                    weakSelf.startTripReminderAlert = nil;
                }]];
                
                weakSelf.startTripReminderAlert = [RAAlertManager showAlertWithTitle:nil
                                                                             message:[@"Did you forget to start the ride?" localized]
                                                                             options:options];
    
                [[SoundManager sharedManager] playSoundWithName:@"RA-Alert" andExtension:@"caf"];
            } else {
                [RAAlertManager showDidYouForgetToStartRideBackgroundLocalNotification];
            }
        }
    }];
}

- (void)autoEndIfDriverIsNearDestination {
    CLLocation *destination = self.rideDataModel.endAddress.location;
    if (destination.isValid) {
        [[LocationService sharedService] observeIfProximity:20 to:destination reachedWithCompletion:^{
            if (self.driverState == OnTripDriverState &&
                [UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
                [RAAlertManager showNearDestinationRideBackgroundLocalNotification];
            }
        }];
    }
}

- (void)didStartTripFromAlerts {
    if (self.driverState == ArrivingToPickUpDriverState) {
        [self didTapStartTrip:self.actionView.btnTrip];
    }
}

- (void)didEndTripFromLocalNotification {
    if (self.driverState == OnTripDriverState) {
        [self didTapEndTrip:self.actionView.btnTrip];
    }
}

#pragma mark - COMPLETING EXISTING RIDE

- (void)prepareForRideCompletion {
    if (self.upgradePopup) {
        [self.upgradePopup dismiss];
    }
    
    if (self.nextRideViewController) {
        [self.nextRideViewController dismiss];
    }
    
    [self.actionView toggleNextAction:Idle];
}

- (void)completeCachingRide {
    [self prepareForRideCompletion];
    RARideDataModel *nextRide = self.rideDataModel.nextRide;
    if (nextRide) {
        [[DriverManager shared] updateDriverStateFromRide:nextRide];
    } else {
        [[DriverManager shared] setRideDataModel:nil andDriverState:AvailableDriverState];
    }
}

- (void)completeEndRide:(RARideDataModel *)endRide {
    [self prepareForRideCompletion];
    [self cleanupRideWithId:endRide.modelID.stringValue];
    [self prepareForRating:endRide];
}

- (void)cleanupRideWithId:(NSString *)rideId {
    [[RASessionManager shared].currentSession terminateRide:@(rideId.longLongValue)];
    [[DriverManager shared] setRideDataModel:nil andDriverState:AvailableDriverState];
    [[RARideCacheManager sharedManager] endCacheForRideWithId:rideId];
    [[DriverManager shared] synchronizeStateWithCompletion:nil];
}

- (void)prepareForRating:(RARideDataModel *)completedRide {
    [PersistenceManager saveUnratedRideData:completedRide];
    [self showRateRideViewWithData:completedRide];
}

- (void)showRateRideViewWithData:(RARideDataModel*)endRide {
    @synchronized (self) {
        if (!self.ratingViewController) {
            __weak LocationViewController *weakSelf = self;
            self.ratingViewController = [[RatingViewController alloc] initWithRideDataModel:endRide completionBlock:^{
                weakSelf.ratingViewController = nil;
                weakSelf.ratingPopUp = nil;
            }];
            
            self.ratingViewController.submitTapped = ^{
                [weakSelf.ratingPopUp dismiss:YES];
            };
            
            self.ratingPopUp = [KLCPopup popupWithContentView:self.ratingViewController.view
                                                     showType:KLCPopupShowTypeBounceIn
                                                  dismissType:KLCPopupDismissTypeBounceOut
                                                     maskType:KLCPopupMaskTypeDimmed
                                     dismissOnBackgroundTouch:NO
                                        dismissOnContentTouch:NO];
            [self.ratingPopUp show];
        }
    }
}

#pragma mark - RideRequestDelegate

- (void)didTimerFinishForEvent:(id<RARideRequestProtocol>)event {
    [self handleMissedRideForEvent:event];
}

- (void)didTapAcceptButtonForEvent:(id<RARideRequestProtocol>)event {
    BFLog(@"didTapAccept from RideRequestViewController");
    [[RACallKitManager sharedManager] endCallWithCompletion:nil];
    [self attemptToAcceptRideForRideRequestEvent:event];
}

- (void)didTapDeclineButtonForEvent:(id<RARideRequestProtocol>)event {
    BFLog(@"didTapDecline from RideRequestViewController");
    [self handleDeclinedRideForEvent:event];
}

- (void)didTapOnlineButtonForEvent:(id<RARideRequestProtocol>)event {
    BFLog(@"didTapOnlineButton from RideRequestViewController");
    [self didTapOnlineButton:nil];
    [self handleDeclinedRideForEvent:event];
}

#pragma mark - Missed/Declined Ride

- (void)handleMissedRideForEvent:(id<RARideRequestProtocol>)event {
    BFLog(@"RideRequest Missed");
    NSNumber *rideID = event.isStackedRide ? event.nextRide.modelID : event.ride.modelID;
    [[RASessionManager shared].currentSession terminateRide:rideID];
    [[RACallKitManager sharedManager] endCallWithCompletion:nil];
}

- (void)handleDeclinedRideForEvent:(id<RARideRequestProtocol>)event {
    BFLog(@"RideRequest Declined");
    NSNumber *rideID = event.isStackedRide ? event.nextRide.modelID : event.ride.modelID;
    [[RASessionManager shared].currentSession terminateRide:rideID];
    if (rideID) {
        [RARideAPI declineRideWithId:rideID andCompletion:nil];
    }
    [[RACallKitManager sharedManager] endCallWithCompletion:nil];
}

#pragma mark -
/**
 *  @brief this will make sure that @b rideRequest.to will be updated and routes will be updated as follows:
 *
 *      @b GoingToPickUpDriverState starts from current to pickup
 *
 *      @b ArrivingToPickUpDriverState starts from current to destination
 *
 *      @b OnTripDriverState starts from current to destination
 *  @param forceUpdate drawRoute as long as its valid
 */
- (void)checkIfDestinationChanged:(CLLocationCoordinate2D)nCoord forceUpdate:(BOOL)forceUpdate {
    __weak __typeof__(self) weakself = self;
    //Skip check if coordinate invalid
    if (![LocationService isCoordinateValidForRide:nCoord]) {
        return;
    }
    
    BOOL isNewCoordinateDifferent = self.rideDataModel.endAddress.latitude.doubleValue  != nCoord.latitude ||
                                    self.rideDataModel.endAddress.longitude.doubleValue != nCoord.longitude;
    
    if (forceUpdate || !self.rideDataModel.endAddress || isNewCoordinateDifferent) {
        
        RARideDataModel *tmpRideDataModel = [self.rideDataModel copy];
        [tmpRideDataModel.endAddress setLocationByCoordinate:nCoord];
        [DriverManager shared].rideDataModel = tmpRideDataModel;
        
        [self drawLocationMarkers];
        
        if ([self.locationViewModel canProceedToCreateRoute]) {
            [self autoSwipeManager];
            
            //Update Route if possible
            [self.googleMapsManager removeRideRoute];
            [self drawRouteForState:self.driverState withBlock:^(CLLocationCoordinate2D startCoordinate, CLLocationCoordinate2D endCoordinate) {
                [weakself.googleMapsManager createRouteFrom:startCoordinate to:endCoordinate completion:nil];
            }];
            
            //Avoid auto-zooming if destination changed while going to pickup rider
            if (self.driverState != GoingToPickUpDriverState) {
                [self updateMapZoomByRidingState];
            }
            
        } else {
            [self.googleMapsManager removeRideRoute];
        }
    }
}

#pragma mark - Google Maps

- (void)findMyLocation {
    const CGFloat kLocationViewControllerMapDefaultZoomAdjustment = 4;
    self.isAllowAutomaticallyMapUpdate = YES;
    [self.googleMapsManager animateCameraToCoordinate:[LocationService sharedService].myLocation.coordinate zoom:kGMSMaxZoomLevel - kLocationViewControllerMapDefaultZoomAdjustment];
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate{
    [self.view endEditing:YES];
}

- (void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture {
    if (gesture) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(enableAutomaticallyMapUpdate) object:nil];
        self.isAllowAutomaticallyMapUpdate = NO;
    }
}

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position {
#ifdef AUTOMATION
    self.googleMapView.accessibilityValue = [NSString stringWithFormat:@"ZOOM:%f;LAT:%f;LNG:%f",position.zoom,position.target.latitude,position.target.longitude];
#endif
    //Wait one minute before update
    if ([self respondsToSelector:@selector(enableAutomaticallyMapUpdate)] && !self.isAllowAutomaticallyMapUpdate) {
        [self performSelector:@selector(enableAutomaticallyMapUpdate) withObject:nil afterDelay:60];
    }
}

- (void)enableAutomaticallyMapUpdate {
    self.isAllowAutomaticallyMapUpdate = YES;
}

- (void)updateMapZoomByRidingState {
    CLLocationCoordinate2D coordinateDriver = [LocationService sharedService].myLocation.coordinate;
    CLLocationCoordinate2D coordinateStart = self.rideDataModel.startAddress.coordinate;
    CLLocationCoordinate2D coordinateEnd   = self.rideDataModel.endAddress.coordinate;
    
    switch (self.driverState) {
        case GoingToPickUpDriverState:
            [self zoomToShowStartMarkerWithLocation:coordinateDriver andEndMarkerWithLocation:coordinateStart];
            break;
            
        case ArrivingToPickUpDriverState:
        case OnTripDriverState:
            [self zoomToShowStartMarkerWithLocation:coordinateDriver andEndMarkerWithLocation:coordinateEnd];
            break;
        
        case OfflineDriverState:
        case AvailableDriverState:
        case AcceptingRequest:
        case InvalidDriverState:
            break;
    }
}

- (void)zoomToShowStartMarkerWithLocation:(CLLocationCoordinate2D)startCoordinate andEndMarkerWithLocation:(CLLocationCoordinate2D)endCoordinate {
    if ([LocationService isCoordinateValidForRide:startCoordinate] && [LocationService isCoordinateValidForRide:endCoordinate]) {
        
        CGFloat topInset = self.riderAddressView.frame.size.height + 85.0;
        UIEdgeInsets insets = UIEdgeInsetsMake(topInset, 25.0, self.actionView.frame.size.height + 50.0, 25.0);
        
        GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:startCoordinate coordinate:endCoordinate];
        GMSCoordinateBounds *routeBounds = [self.googleMapsManager boundsForRouteWithIdentifier:kRideRoutePath];
        if (routeBounds) {
            bounds = [bounds includingBounds:routeBounds];
        }
        
        [self.googleMapsManager animateCameraToFitBounds:bounds withEdgeInsets:insets];
    }
}

#pragma mark - Show Error Functions

- (void)showAlertOfflineForMissedRidesWithMessage:(NSString *)message {
    
    if (self.isLocalNotificationDisplayed) {
        return;
    }
    
    self.isLocalNotificationDisplayed = YES;
    
    [RAAlertManager showAlertMarkedOfflineWithMessage:message];
    
    //FIX: RA-5893 - reset after 15 seconds to avoid buffered notifications
    if ([self respondsToSelector:@selector(resetLocalNotificationDisplayed)]) {
        [self performSelector:@selector(resetLocalNotificationDisplayed) withObject:self afterDelay:15];
    }
}

- (void)resetLocalNotificationDisplayed {
    self.isLocalNotificationDisplayed = NO;
}

#pragma mark - Markers

- (void)drawLocationMarkers {
    //Draw Pickup Marker
    if (self.rideDataModel.startAddress.isValid) {
        [self.googleMapsManager createOrUpdatePickupMarkerWithCoordinate:self.rideDataModel.startAddress.coordinate];
    } else {
        [self.googleMapsManager removePickupMarker];
    }
    
    //Draw Destination Marker
    BOOL hasValidDestination = self.rideDataModel.endAddress != nil && self.rideDataModel.endAddress.isValid;
    if (hasValidDestination && self.locationViewModel.canShowDestination) {
        [self.googleMapsManager createOrUpdateDestinationMarkerWithCoordinate:self.rideDataModel.endAddress.coordinate];
    } else {
        [self.googleMapsManager removeDestinationMarker];
    }
}

- (void)drawRouteForState:(DriverState)driverState withBlock:(void(^)(CLLocationCoordinate2D startCoordinate, CLLocationCoordinate2D endCoordinate))routeDrawBlock {
    CLLocationCoordinate2D startCoordinate = [self.locationViewModel startCoordinateForRouteOnDriverState:driverState];
    CLLocationCoordinate2D endCoordinate = [self.locationViewModel endCoordinateForRouteOnDriverState:driverState];
    if (CLLocationCoordinate2DIsValid(startCoordinate) && CLLocationCoordinate2DIsValid(endCoordinate)) {
        routeDrawBlock(startCoordinate, endCoordinate);
    } else {
        [self.googleMapsManager removeRideRoute];
    }
}

- (void)showRiderMarkerAt:(CLLocation *)riderLocation withRecordDate:(NSDate *)recordDate {
    if (riderLocation.isValid) {
        [self.googleMapsManager createOrUpdateRiderMarkerWithCoordinate:riderLocation.coordinate];
    } else {
        [self.googleMapsManager removeRiderMarker];
    }
}

- (void)hideRiderMarkerForState:(DriverState)driverState {
    switch (driverState) {
        case OnTripDriverState:
        case OfflineDriverState:
        case AvailableDriverState:
            [self.googleMapsManager removeRiderMarker];
            break;
        case InvalidDriverState:
        case GoingToPickUpDriverState:
        case ArrivingToPickUpDriverState:
        case AcceptingRequest:
            break;
    }
}

#pragma mark Queue Events

- (BOOL)shouldNotifyQueueWithEvent:(DriverEventType)event andPositions:(NSDictionary*)positions {
    if (event != QueueUpdate) {
        return YES;
    }
    
    const NSInteger minPlaceInQueueToNotify = 10;
    
    NSArray<NSString *> *userCarTypes = [RASessionManager shared].currentSession.userCarTypes;
    for (NSString *carType in userCarTypes) {
        id position = positions[carType];
        if (position && [position integerValue] < minPlaceInQueueToNotify) {
            return YES;
        }
    }
    
    return NO;
}

- (void)showQueueMessageForEvent:(QueueEvent *)queueEvent withPositions:(NSDictionary *)positions {
    NSString *message = nil;
    DriverEventType event = queueEvent.eventType;
    switch (event) {
        case QueueEntering:
        case QueueUpdate:
            if (positions) {
                message = [NSString queueUpdateMessageWithEvent:queueEvent fromPositions:positions];
                if (message) {
                    [RAAlertManager showQueueAlert:queueEvent withMessage:message];
                }
            }
            break;
        case QueueLeavingArea:
        case QueueLeavingInactive:
            [RAAlertManager showQueueAlert:queueEvent withMessage:queueEvent.alertMessage];
            break;
        case QueueLeavingInARide:
            break;
        default:
            break;
    }
}

- (void)setPickupTextField:(NSString *)pickupText {
    self.riderAddressView_pickup.text = pickupText;
    if (self.rideDataModel && (pickupText == nil || pickupText.trim.length == 0)) {
        NSDictionary *dictRide = [MTLJSONAdapter JSONDictionaryFromModel:self.rideDataModel error:nil];
        [ErrorReporter recordErrorDomainName:WATCHPickupLocation withUserInfo:dictRide];
    }
}

- (IBAction)btnNavigateTapped:(UIButton *)sender {
    CLLocation *destinationLocation = self.locationViewModel.destinationToShowBasedOnStateForCurrentRide;
    if (destinationLocation && destinationLocation.isValid) {
        if ([PersistenceManager hasDefaultNavigationApp]) {
            NavigationApp defaultNavigationApp = [PersistenceManager cachedDefaultNavigationApp];
            [self openNavigationApp:defaultNavigationApp withDestination:destinationLocation];
            
        } else {
            __weak LocationViewController *weakSelf = self;
            UIAlertController *navigationAppController = [UIAlertController alertControllerWithTitle:[@"Navigation App" localized] message:[@"Which app would you prefer to use?" localized] preferredStyle:UIAlertControllerStyleActionSheet];
            
            //Waze App Actions
            UIAlertAction *wazeMapsAction = [UIAlertAction actionWithTitle:@"Waze" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf openNavigationApp:WazeApp withDestination:destinationLocation];
            }];
            
            //Google Maps Actions
            UIAlertAction *googleMapsAction = [UIAlertAction actionWithTitle:@"Google Maps" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf openNavigationApp:GoogleMapApp withDestination:destinationLocation];
            }];
            
            //Apple Maps Actions
            UIAlertAction *appleMapsAction = [UIAlertAction actionWithTitle:@"Apple Maps" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf openNavigationApp:AppleMaps withDestination:destinationLocation];
            }];
            
            [navigationAppController addAction:wazeMapsAction];
            [navigationAppController addAction:googleMapsAction];
            [navigationAppController addAction:appleMapsAction];
            [navigationAppController addAction:[UIAlertAction actionWithTitle:[@"Cancel" localized] style:UIAlertActionStyleCancel handler:nil]];
            
            navigationAppController.popoverPresentationController.sourceView = sender;
            
            [self presentViewController:navigationAppController animated:true completion:nil];
        }
    } else {
        [RAAlertManager showAlertWithTitle:[ConfigurationManager appName]
                                   message:[@"No Destination is selected by Rider to show navigation" localized]];
    }
}

- (void)openNavigationApp:(NavigationApp)navigationApp withDestination:(CLLocation*)destinationLocation {
    if ([[UIApplication sharedApplication] canOpenURL:[NavigationAppUtil urlToOpen:navigationApp]]) {
        
        if (![PersistenceManager hasDefaultNavigationApp]){
            UIAlertController *defaultAlert = [UIAlertController alertControllerWithTitle:[ConfigurationManager appName] message:[NSString stringWithFormat:[@"Do you want to set %@ as default navigation app? You can change later in settings." localized], [NavigationAppUtil nameApp:navigationApp]] preferredStyle:UIAlertControllerStyleAlert];
            
            [defaultAlert addAction:[UIAlertAction actionWithTitle:[@"Cancel" localized] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [self autoStartTripWhenMoveToNavigationApp];
                [[UIApplication sharedApplication] openURL:[NavigationAppUtil directionURL:navigationApp WithDestination:destinationLocation]];
            }]];
            
            [defaultAlert addAction:[UIAlertAction actionWithTitle:[@"Yes" localized] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [PersistenceManager saveDefaultNavigationApp:navigationApp];
                [self autoStartTripWhenMoveToNavigationApp];
                [[UIApplication sharedApplication] openURL:[NavigationAppUtil directionURL:navigationApp WithDestination:destinationLocation]];
            }]];
            
            [self presentViewController:defaultAlert animated:YES completion:nil];
            
        }else{
            [self autoStartTripWhenMoveToNavigationApp];
            [[UIApplication sharedApplication] openURL:[NavigationAppUtil directionURL:navigationApp WithDestination:destinationLocation]];
        }

    } else {
        [self showAlertToInstallNavigationApp:navigationApp];
    }
}

- (void)autoStartTripWhenMoveToNavigationApp {
    // auto start when driver hits navigate while ArrivingToPickUpDriverState
    if (self.driverState == ArrivingToPickUpDriverState) {
        [self didTapStartTrip:self.actionView.btnTrip];
    }
}

@end

#pragma mark RiderLocation Expiration Timer

@implementation LocationViewController (RiderLocationExpiration)

- (void)restartRiderLocationTimer {
    self.riderLocationExpirationTime = [[ConfigurationManager shared].global.liveLocation.expirationTime doubleValue];
    [self startRiderLocationTimer];
}

- (void)startRiderLocationTimer {
    [self stopRiderLocationTimer];
    self.riderLocationExpirationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(riderLocationTimerExecution) userInfo:nil repeats:YES];
}

- (void)riderLocationTimerExecution {
    self.riderLocationExpirationTime--;
    if (self.riderLocationExpirationTime <= 0) {
        [self stopRiderLocationTimer];
        [self riderLocationHasExpired];
    }
}

- (void)stopRiderLocationTimer {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(riderLocationHasExpired) object:nil];
    [self.riderLocationExpirationTimer invalidate];
    self.riderLocationExpirationTimer = nil;
}

- (void)riderLocationHasExpired {
    [self.googleMapsManager removeRiderMarker];
}

@end

#pragma mark - Location Update

@implementation LocationViewController (LocationUpdate)

- (void)configureLocationService {
    [[LocationService sharedService] setDelegate:self];
    [[LocationService sharedService] checkIfNeedToNotifyChangeOfAuthorizationToAlways];
}

- (void)locationUpdateCarIconCoordinate:(CLLocationCoordinate2D)coordinate andDirection:(CLLocationDirection)direction {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        //Update driver Car
        [self.googleMapsManager updateCarWithHeading:direction];
        [self.googleMapsManager updateCarWithCoordinate:coordinate];
        
        BOOL isBackgroundMode = [UIApplication sharedApplication].applicationState != UIApplicationStateActive;
        if (isBackgroundMode) {
            //no need to update route/pins in the background
            return;
        }
        
        //Draw pins
        [self drawLocationMarkers];
        
        //Draw Route if Posible
        [self drawRouteForState:self.driverState withBlock:^(CLLocationCoordinate2D startCoordinate, CLLocationCoordinate2D endCoordinate) {
            [self.googleMapsManager attempToDrawRouteFrom:startCoordinate to:endCoordinate];
        }];
        
        //Driver moved the map recently
        if (!self.isAllowAutomaticallyMapUpdate) {
            return;
        }
        
        if ([[DriverManager shared] isDriverOnActiveRide] && [self.locationViewModel canProceedToCreateRoute]) {
            //Fit bounds between driver coordinate and pickup/destionation
            [self updateMapZoomByRidingState];
        } else {
            //Follow the driver position when not in Ride or can't create route
            [self.googleMapsManager animateToLocation:coordinate];
        }
    }];
}

- (void)notifyUserToChangeAuthorizationToAlways {
    __weak LocationViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController
        = [UIAlertController alertControllerWithTitle:@"Location Settings"
                                              message:[ConfigurationManager shared].global.driverMessages.locationSettingsAlwaysPrompt
                                       preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:[@"Cancel" localized] style:UIAlertActionStyleCancel handler:nil]];
        
        NSURL *urlSettings = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:urlSettings]) {
            [alertController addAction:[UIAlertAction actionWithTitle:[@"Go to Settings" localized] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[UIApplication sharedApplication] openURL:urlSettings];
            }]];
        }
        
        [weakSelf presentViewController:alertController animated:YES completion:nil];
    });
}

@end

#pragma mark - UNRATED RIDE

@implementation LocationViewController (UnratedRide)

- (void)checkUnratedRides {
    if ([PersistenceManager hasUnratedRide]) {
        RARideDataModel *unratedRide = [PersistenceManager cachedUnratedRides].firstObject;
        if (unratedRide) {
            [self showRateRideViewWithData:unratedRide];
        }
    }
}

@end

@implementation LocationViewController (CancellationFeedback)

- (UIViewController *)showCancellationFeedbackScreenForRide:(RARideDataModel *)ride {
    CFFormViewController *vc = [[UIStoryboard storyboardWithName:@"Overlays" bundle:nil] instantiateViewControllerWithIdentifier:CFFormViewController.className];
    [vc setRide:ride];
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    __weak __typeof__(self) weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        BFLog(@"Showing cancellation feedback screen for ride with id: %@", ride.modelID);
        [weakself.navigationController presentViewController:vc animated:YES completion:nil];
    });
    return vc;
}

- (UIViewController *)showCancellationConfirmationForRide:(RARideDataModel *)ride {
    __weak __typeof__(self) weakself = self;
    RAAlertOption *option = [RAAlertOption optionWithState:StateActive];
    [option addAction:[RAAlertAction actionWithTitle:[@"NO" localized] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nullable action) {
        BFLog(@"Driver select (NO) from cancel alert for ride with Id : %@",ride.modelID);
    }]];
    [option addAction:[RAAlertAction actionWithTitle:[@"YES" localized] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nullable action) {
        BFLog(@"Driver select (YES) from cancel alert for ride with Id : %@",ride.modelID);
        [weakself showHUD];
        [[DriverManager shared] cancelTripWithCompletion:^(NSError * _Nullable error) {
            [weakself hideHUD];
            if (error) {
                [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateAll andShownOption:AllowNetworkError]];
                if (error.code == 400 || error.code == 403) {
                    [weakself.eventPolling start];
                }
            }
        }];
    }]];
    return [RAAlertManager showAlertWithTitle:nil message:[@"Are you sure you want to cancel?" localized] options:option];
}

@end

#pragma mark - DriverActionButtton

@implementation LocationViewController (DriverState)

- (void)updateButtonViewNoTrip {
    [self.actionView setHidden:YES];
    self.riderAddressView.hidden = YES;
    self.riderAddressView_dropoff.text = nil;
    self.riderAddressView_dropoff.hidden = YES;
    [self setRiderComment:nil];
}

- (void)updateButtonViewForArriving {
    [self.actionView setHidden:NO];
    [self.actionView toggleNextAction:Arrived];

    self.constraintDestinationTop.constant = -50;
    self.riderAddressView.hidden = NO;
    [UIView animateWithDuration:0.5 animations:^{
        [self.riderAddressView_dropoff setHidden:YES];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self showOrHideRiderCommentAnimated:YES];
    }];
}

- (void)updateButtonViewForStartRide {
    [self.actionView setHidden:NO];
    [self.actionView toggleNextAction:Begin];
    self.constraintDestinationTop.constant = -10;
    self.riderAddressView.hidden = NO;
    [UIView animateWithDuration:0.5 animations:^{
        [self.riderAddressView_dropoff setHidden:NO];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self showOrHideRiderCommentAnimated:YES];
    }];
}

- (void)updateButtonViewForEndRide {
    [self.actionView setHidden:NO];
    [self.actionView toggleNextAction:End];
    self.constraintDestinationTop.constant = -10;
    self.riderAddressView.hidden = NO;
    [UIView animateWithDuration:0.5 animations:^{
        [self.riderAddressView_dropoff setHidden:NO];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self hideRiderCommentAnimated:YES];
    }];
}

- (void)updateActionButtonsForState:(DriverState)driverState {
    switch (driverState) {
        case InvalidDriverState:
        case OfflineDriverState:
        case AvailableDriverState:
        case AcceptingRequest:
            [self.btnNavigateTrip setHidden:YES];
            [self.btnCancelTrip   setHidden:YES];
            [self.btnNextRide setHidden:YES];
            break;
        case GoingToPickUpDriverState:
        case ArrivingToPickUpDriverState:
            [self.btnNavigateTrip setHidden:NO];
            [self.btnCancelTrip   setHidden:NO];
            [self.btnNextRide setHidden:YES];
            break;
        case OnTripDriverState:
            [self.btnNavigateTrip setHidden:NO];
            [self.btnCancelTrip   setHidden:YES];
            [self.btnNextRide setHidden:self.rideDataModel.nextRide == nil];
            break;
    }
}

- (void)updateDriverBtnWithState:(DriverState)driverState andRideDataModel:(RARideDataModel *)rideDataModel {
    [self updateActionButtonsForState:driverState];
    switch (driverState) {
        case InvalidDriverState:
        case OfflineDriverState:
        case AvailableDriverState:
        case AcceptingRequest:
            [self.driverStatusButton setStatusBasedOnAvailability];
            [self updateButtonViewNoTrip];
            [self placeDriverStatusButtonInNavigationBar];
            break;
            
        case GoingToPickUpDriverState:
            [self.driverStatusButton setStatus:DABSHidden];
            [self updateButtonViewForArriving];
            [self setupNavigationTitleWithTitle:rideDataModel.rider.firstName andSubtitle:rideDataModel.requestedCarType.title];
            break;

        case ArrivingToPickUpDriverState:
            [self.driverStatusButton setStatus:DABSHidden];
            [self updateButtonViewForStartRide];
            [self setupNavigationTitleWithTitle:rideDataModel.rider.firstName andSubtitle:rideDataModel.requestedCarType.title];
            break;
            
        case OnTripDriverState:
            [self.driverStatusButton setStatus:DABSHidden];
            [self updateButtonViewForEndRide];
            [self setupNavigationTitleWithTitle:rideDataModel.rider.firstName andSubtitle:rideDataModel.requestedCarType.title];
            break;
    }
    
    //Adjust Margin if viewDriverUsageActionButtons are present
    switch (driverState) {
        case GoingToPickUpDriverState:
        case ArrivingToPickUpDriverState:
        case OnTripDriverState:
            [self addPaddingToGoogleMapView:YES];
            break;
        default:
            [self addPaddingToGoogleMapView:NO];
    }
}

- (void)addPaddingToGoogleMapView:(BOOL)apply {
    CGFloat bottomOffset = apply ? self.actionView.bounds.size.height + 16.0 : 12.0;
    self.constraintBottomFloatingMenu.constant = bottomOffset;
    
    [self.googleMapsManager setPadding:UIEdgeInsetsMake(0.0, 0.0, bottomOffset, 12.0)];
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}

@end

#pragma mark - ActiveDrivers

@implementation LocationViewController (ActiveDrivers)

- (void)showActiveDrivers:(NSArray *)drivers {
    NSInteger currentUserId = [RASessionManager shared].currentSession.driver.user.modelID.integerValue;
    [self.googleMapsManager showNearbyDriversWithList:drivers excludingCurrentUser:currentUserId];
}

- (void)clearActiveDrivers {
    [self.googleMapsManager removeAllNearbyDrivers];
}

@end

#pragma mark Ride Cache Notifications

@implementation LocationViewController (RideCacheNotifications)

- (void)willFlushRideCacheData {
    [self.driverStatusButton setStatus:DABSLoading];
}

- (void)didFlushRideCacheDataSuccessfully:(BOOL)success {
    if (!success) {
        [self.eventPolling start];
        [self.driverStatusButton setStatus:DABSSync];
    } else {
        __weak LocationViewController *weakself = self;
        [[DriverManager shared] synchronizeStateWithCompletion:^(DriverState state, RARideDataModel * _Nullable ride) {
            [weakself.eventPolling start];
        }];
    }
}

@end

#pragma mark - Floating Menu

@implementation LocationViewController (FloatingMenu)

- (IBAction)tapFloatingMenu:(id)sender {
    if ([self.btnFloatingMenu isOpening]) {
        return;
    }
    
    const CGFloat alphaValue = self.btnFloatingMenu.isClosed ? 0.5 : 0;
    if (self.btnFloatingMenu.isClosed) {
        [self.floatingMenuDataSourceAndDelegate reloadItems];
        [self.btnFloatingMenu open];
    } else {
        [self.btnFloatingMenu close];
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        self.vFloatingOverlay.alpha = alphaValue;
    }];
}

- (void)closeFloatingMenuIfNeeded {
    if (![self.btnFloatingMenu isClosed]) {
        [self tapFloatingMenu:self.btnFloatingMenu];
    }
}

/**
 Make sure the floating menu is closed or updated when ride is accepted or cancelled
 */
- (void)updateFloatingMenuWithDriverState:(DriverState)driverState {
    if (self.btnFloatingMenu.isClosed == NO) {
        switch (driverState) {
            case InvalidDriverState:
            case OfflineDriverState:
                break;
            case GoingToPickUpDriverState:
            case ArrivingToPickUpDriverState:
            case OnTripDriverState:
            case AvailableDriverState:
            case AcceptingRequest:
                [self closeFloatingMenuIfNeeded];
                break;
        }
    }
}

@end

#pragma mark - Upgrade Popup Delegate

@implementation LocationViewController (UpgradePopup)

- (void)didTapCancel:(RAUpgradePopup *)upgradePopup {
    __weak LocationViewController *weakSelf = self;
    [self showHUD];
    [RARideAPI declineUpgradeWithCompletion:^(NSString *message, NSError *error) {
        [weakSelf hideHUD];
        if (error) {
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive]];
            return;
        }
        weakSelf.rideDataModel.rideRequestUpgrade.status = UpgradeInvalid;
        [upgradePopup dismiss];
    }];
}

- (void)didTapClose:(RAUpgradePopup *)upgradePopup {
    self.upgradePopup = nil;
}

@end

#pragma mark - EventPolling Delegate

@implementation LocationViewController (EventPollingHandler)

- (void)handleInactiveEvent:(id<RAInactiveEventProtocol>)event {
    [DriverManager updateDriverState:OfflineDriverState];
    [[RACallKitManager sharedManager] endCallWithCompletion:nil];
    
    switch (event.source) {
        case TermsNotAccepted:
            [RASessionManager shared].currentSession.driver.agreedToLegalTerms = NO;
            [self askConfirmationToReadNewTermsAndConditionsWithMessage:event.reason];
            break;
        case InactiveSourceUnknown:
        case NoLocationUpdate:
        case MissedRides:
        case CarTypesDeactivate:
            [self showAlertOfflineForMissedRidesWithMessage:event.reason];
            break;
    }
}

- (void)handleHandShakeEvent:(id<RAHandShakeEventProtocol>)event {
    if (event.remainingHandShakeExpiration <= 0) {
        BFLogErr(@"HandShake Request expired with remaining [handShakeExpiration : %f]", event.remainingHandShakeExpiration);
        return;
    }
    
    [RARideAPI ackReceivedRideWithId:event.rideId completion:^(NSInteger statusCode, NSError *error) {
        if (!error) {
            BFLog(@"Ack sent to server, for ride with Id: %@",event.rideId);
        } else {
            BFLogErr(@"Error while sending ack to server : %@",error);
        }
    }];
}

- (void)handleRideRequestedEvent:(id<RARideRequestProtocol>)event {
    
    if (![self.locationViewModel shouldPresentRideRequestFromEvent:event onDriverState:self.driverState]) {
        return;
    }
    
    RARideDataModel *ride = event.isStackedRide ? event.nextRide : event.ride;
    if (![ride isValid]) {
        BFLogErr(@"RARideDataModel's ride with id %@ is not valid",ride.modelID);
        return;
    }
    
    if (event.remainingAcceptanceExpiration <= 0) {
        BFLogErr(@"RideRequest with id %@ Expired with remaining [acceptance : %f]",ride.modelID, event.remainingAcceptanceExpiration);
        return;
    }
    [self showRideRequestViewControllerWithEvent:event];
    [self handleRideRequestedInBackgroundWithEvent:event];
}

- (void)showRideRequestViewControllerWithEvent:(id<RARideRequestProtocol>)event {
    RARideDataModel *ride = event.isStackedRide ? event.nextRide : event.ride;
    [[RASessionManager shared].currentSession acknowledgeRide:ride.modelID];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popToViewController:self animated:YES];
    if (self.rideRequestViewController) {
        [self.rideRequestViewController dismissViewControllerAnimated:NO completion:nil];
    }
    
    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateBackground) {
        [[SoundManager sharedManager] playSound:SMSReceived_Selection15];
    }
    
    self.rideRequestViewController = (RideRequestViewController*)[self createViewControllerFromStoryboard:@"Overlays" withIdentifier:@"RideRequestViewController"];
    self.rideRequestViewController.event = event;
    GMSMarker *carMarker = [self.googleMapsManager carMarker];
    if (!carMarker) {
        [self.googleMapsManager createCarMarkerWithCoordinate:self.googleMapView.camera.target];
        carMarker = [self.googleMapsManager carMarker];
    }
    self.rideRequestViewController.tmpCarIcon = carMarker;
    self.rideRequestViewController.rideRequestDelegate = self;
    [self.rideRequestViewController showAnimated:NO];
}

- (void)handleRideRequestedInBackgroundWithEvent:(id<RARideRequestProtocol>)event {

    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        return;
    }
    
    BFLog(@"Handle Ride Request Event in Background");
    
    NSString *bodyMessage = [self.locationViewModel rideRequestNotificationBodyFromEvent:event];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 10.0) {
        BFLog(@"Show RideRequest Local Notification ~ iOS < 10.0");
        RAAlertNotificationOption *option = [RAAlertNotificationOption notificationOptionWithState:StateBackground andAlertActionTitle:@"Accept Ride" userInfo:@{@"notificationName" : kAcceptRideRequestNotification, @"event" : event}];
        [RAAlertManager showLocalNotificationWithTitle:[@"Ride Request received!" localized] message:bodyMessage andNotificationOption:option];
        
    } else {
        BFLog(@"Show RideRequest CallKit");
        __block BOOL didRespondToCall = NO;
        __weak LocationViewController *weakSelf = self;
        NSString *callName = [self.locationViewModel rideRequestCallKitNameFromEvent:event];
        RARideDataModel *rideDataModel = event.isStackedRide ? event.nextRide : event.ride;
        [[RACallKitManager sharedManager] reportIncomingCallForRideWithId:rideDataModel.modelID.stringValue name:callName title:bodyMessage completion:^(RARequestRideCall *call, NSError *error) {
            if ([call answered]) {
                [DriverManager updateDriverState:AcceptingRequest];
                if ([PersistenceManager hasCallSetting]) {
                    CallSetting callSetting = [PersistenceManager cachedCallSetting];
                    switch (callSetting) {
                        case AcceptRequest:
                            [weakSelf.rideRequestViewController dismissRequestView];
                            [weakSelf attemptToAcceptRideForRideRequestEvent:event];
                            break;
                        case OpenApp:
                        default:
                            BFLog(@"RideRequest Open App from CallKit");
                            break;
                    }
                } else {
                    [weakSelf attemptToAcceptRideForRideRequestEvent:event];
                }
            } else {
                [weakSelf.rideRequestViewController dismissRequestView];
                if (call.declined) {
                    [weakSelf handleDeclinedRideForEvent:event];
                } else {
                    [weakSelf handleMissedRideForEvent:event];
                }
            }
        }];
        
        double declineRequestTimeout = [ConfigurationManager shared].global.rideAcceptance.acceptancePeriod.doubleValue;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(declineRequestTimeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            BOOL didMissTheCallInTheBackground = [UIApplication sharedApplication].applicationState == UIApplicationStateBackground && didRespondToCall == NO;
            if (didMissTheCallInTheBackground) {
                [[RACallKitManager sharedManager] endCallWithCompletion:nil];
            } else {
                DBLog(@"didn't miss the call");
            }
        });
    }
}

- (void)handleRiderCancelledEvent:(RAEventDataModel *)event {
    //RA-5310 Hide the RequestViewController / End Call
    [self.rideRequestViewController dismissViewControllerAnimated:NO completion:nil];
    [[RACallKitManager sharedManager] endCallWithCompletion:nil];
    
    [self dismissPresentedViewControllers];
    
    BOOL isStackedRide = ![self.rideDataModel.modelID isEqualToNumber:event.ride.modelID];
    //RA-14558 notify before cleaning ride
    if ([[RASessionManager shared].currentSession shouldShowCancelledRide:event.ride.modelID]) {
        [self showRiderCancelledRide:event.ride isStackedRide:isStackedRide];
    }
    
    if (isStackedRide) {
        [[DriverManager shared] setNextRide:nil];
    } else {
        [DriverManager updateDriverState:AvailableDriverState];
        [self cleanupRideWithId:event.ride.modelID.stringValue];
    }
}

- (void)showRiderCancelledRide:(RARideDataModel *)ride isStackedRide:(BOOL)isStackedRide {
    [[SoundManager sharedManager] playSound:CalendarAlert];//1005
    NSString *firstname = ride.rider.firstName ?: [@"Rider" localized];
    NSNumber *driverPayment = ride.driverPayment;
    
    NSMutableString *message = [NSMutableString new];
    [message appendFormat:[@"%@ has cancelled the " localized], firstname];
    if (isStackedRide) {
        [message appendString:[@"next " localized]];
    }
    [message appendString:[@"trip." localized]];

    if (driverPayment != nil && driverPayment.doubleValue != 0) {
        [message appendFormat:[@"\nYou will receive $%@ for trip cancellation." localized], driverPayment];
    }
    
    [RAAlertManager showCancelledRideAlertWithMessage:message];
}

- (void)handleDriverCancelledEvent:(RAEventDataModel *)event {
    [[SoundManager sharedManager] playSound:CalendarAlert];//1005
    BOOL isStackedRide = ![self.rideDataModel.modelID isEqualToNumber:event.ride.modelID];
    if (!isStackedRide) {
        [DriverManager updateDriverState:AvailableDriverState];
        [self cleanupRideWithId:event.ride.modelID.stringValue];
    }
    
    NSNumber *driverPayment = event.ride.driverPayment;
    NSMutableString *message = [NSMutableString new];
    [message appendString:[@"Your " localized]];
    if (isStackedRide) {
        [message appendString:[@"next " localized]];
    }
    [message appendString:[@"trip has been cancelled." localized]];
    if (driverPayment != nil && driverPayment.doubleValue != 0) {
        [message appendFormat:[@"\nYou will receive $%@ for trip cancellation." localized], driverPayment];
    }
    
    [RAAlertManager showCancelledRideAlertWithMessage:message];
}

- (void)handleAdminCancelledEvent:(RAEventDataModel *)event {
    NSNumber *rideId = event.ride.modelID;
    [self.rideRequestViewController dismissRequestViewForRideRequestWithId:rideId.stringValue];
    [[RACallKitManager sharedManager] endCallForRideWithId:rideId.stringValue completion:nil];
    
    [[SoundManager sharedManager] playSound:CalendarAlert];
    
    [self dismissPresentedViewControllers];
    
    BOOL isStackedRide = self.rideDataModel && ![self.rideDataModel.modelID isEqualToNumber:rideId];
    if (isStackedRide) {
        [[DriverManager shared] setNextRide:nil];
    } else {
        [DriverManager updateDriverState:AvailableDriverState];
        [self cleanupRideWithId:event.ride.modelID.stringValue];
    }
    
    NSString *riderName = isStackedRide ? event.ride.rider.firstName : self.rideDataModel.rider.firstName;
    
    NSMutableString *message = [NSMutableString new];
    [message appendString:[@"Your " localized]];
    if (isStackedRide) {
        [message appendString:[@"next " localized]];
    }
    [message appendString:[@"trip " localized]];
    if (riderName) {
        [message appendFormat:[@"with %@ " localized], riderName];
    }
    [message appendString:[@"has been cancelled by Admin" localized]];
    [RAAlertManager showCancelledRideAlertWithMessage:message];
}

- (void)dismissPresentedViewControllers {
    __weak __typeof__(self) weakself = self;
    if (self.startTripReminderAlert) {
        [self.startTripReminderAlert dismissViewControllerAnimated:YES completion:^{
            weakself.startTripReminderAlert = nil;
        }];
    }
    
    if (self.nextRideViewController) {
        [self.nextRideViewController dismiss];
    };
    
    if (self.cancellationPromptViewController) {
        [self.cancellationPromptViewController dismissViewControllerAnimated:YES completion:^{
            weakself.cancellationPromptViewController = nil;
        }];
    }
}

- (void)handleDestinationUpdated:(RAEventDataModel *)event {
    RARideDataModel *rideDataModel = event.ride;
    
    BOOL isStackedRide = ![self.rideDataModel.modelID isEqualToNumber:rideDataModel.modelID];
    if (isStackedRide) {
        [self.rideDataModel setNextRide:rideDataModel];
    } else {
        if (rideDataModel.isValid) {
            DriverState driverState = [DriverManager shared].driverState;
            if (driverState == ArrivingToPickUpDriverState || driverState == OnTripDriverState) {
                NSString *message = [NSString stringWithFormat:@"%@ has changed the destination.", rideDataModel.rider.firstName];
                [RAAlertManager showLocalNotificationWithTitle:@"Destination Changed" message:message andNotificationOption:[RAAlertNotificationOption notificationOptionWithState:StateAll andAlertActionTitle:nil]];
                [[SoundManager sharedManager] playSound:SMSReceived];
            }
            
            //RA-4348
            NSString *address = rideDataModel.endAddress.address;
            if (address) {
                RARideDataModel *tmpRideDataModel = [self.rideDataModel copy];
                tmpRideDataModel.endAddress.address = address;
                [DriverManager shared].rideDataModel = tmpRideDataModel;
            } else {
                [[GeocodeService sharedInstance] reverseGeo:rideDataModel.endAddress.location completeBlock:^(NSString *zip, NSString *address, NSString *fullAddress, NSString *city, NSString *state, NSString *county, NSString *neighborhood, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (!error) {
                            RARideDataModel *tmpRideDataModel = [self.rideDataModel copy];
                            tmpRideDataModel.endAddress.address = address;
                            tmpRideDataModel.endAddress.zipCode = zip;
                            [DriverManager shared].rideDataModel = tmpRideDataModel;
                        }
                    });
                }];
            }
            
            if (rideDataModel.endAddress.isValid) {
                [self checkIfDestinationChanged:rideDataModel.endAddress.coordinate forceUpdate:NO];
            } else {
                [RARideAPI getRideWithId:self.rideDataModel.modelID.stringValue andCompletion:^(RARideDataModel *ride, NSError *error) {
                    if (error) {
                        [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithShownOption:AllowNetworkError]];
                    } else {
                        RARideDataModel *tmpRideDataModel = [self.rideDataModel copy];
                        tmpRideDataModel.endAddress.address = ride.endAddress.address;
                        [self checkIfDestinationChanged:ride.endAddress.coordinate forceUpdate:NO];
                    }
                }];
            }
        }
    }
}

- (void)handleRideUpgradeEvent:(RAEventDataModel<RARideUpgradeEventProtocol>*)event {
    if (!self.rideDataModel) {
        return;
    }
    
    [self closeFloatingMenuIfNeeded];
    
    if (event.type == RideUpgradeRejected) {
        //Check if the event received is for the current Ride
        if (event.rideId && [event.rideId isEqualToNumber:self.rideDataModel.modelID]) {
            self.rideDataModel.rideRequestUpgrade.status = UpgradeDeclined;
            [self showUpgradePopupWithRideRequestUpgrade:self.rideDataModel.rideRequestUpgrade];
        }
        return;
    }
    RARideDataModel *ride = event.ride;
    if (ride && [ride.modelID isEqualToNumber:self.rideDataModel.modelID]) {
        [DriverManager shared].rideDataModel = ride;
        [self updateDriverBtnWithState:self.driverState andRideDataModel:ride];
        [self showUpgradePopupWithRideRequestUpgrade:ride.rideRequestUpgrade];
    }
}

- (void)handleStackedRideReassigned:(RAEventDataModel *)event {
    RARideDataModel *nextRide = [DriverManager shared].nextRideDataModel;
    if (nextRide && [nextRide.modelID isEqualToNumber:event.ride.modelID]) {
        [[DriverManager shared] setNextRide:nil];
    }
    if (event.message) {
        [RAAlertManager showCustomMessageWithTitle:event.title andMessage:event.message];
    }
}

- (void)handleRiderLocationUpdatedEvent:(id<RARiderLocationUpdateProtocol>)event {
    if (self.driverState == GoingToPickUpDriverState || self.driverState == ArrivingToPickUpDriverState) {
        [self restartRiderLocationTimer];
        [self showRiderMarkerAt:event.location withRecordDate:event.timeStamp];
    }
}

- (void)handleQueueEvent:(RAEventDataModel *)eventModel {
    NSNumber *driverId = [RASessionManager shared].currentSession.driver.modelID;
    DriverEventType event = eventModel.type;
    QueueEvent *queueEvent = [QueueEvent eventWithType:event andAreaQueueName:eventModel.areaQueueName];
    BFLog(@"%@", queueEvent);
    [[NetworkManager sharedInstance] getPositionForDriver:driverId withCompletion:^(NSDictionary *object, NSError *error) {
        NSDictionary *positions = object[@"positions"];
        BOOL hasPositions = [positions isKindOfClass:[NSDictionary class]];
        if (hasPositions && self.queueEventsDelegate) {
            
            if (!object[@"areaQueueName"]) {
                NSMutableDictionary *queueResponse = object.mutableCopy;
                [queueResponse setObject:queueEvent.areaQueueName forKey:@"areaQueueName"];
                object = queueResponse;
            }
            
            switch (event) {
                case QueueEntering:
                case QueueUpdate:
                case QueueLeavingArea:
                case QueueLeavingInactive:
                case QueueLeavingInARide:
                    [self.queueEventsDelegate queueUpdatedWithResponse:object];
                    break;
                default:
                    break;
            }
        }
        
        if (![[DriverManager shared] isDriverOnActiveRide] && [self shouldNotifyQueueWithEvent:event andPositions:positions]) {
            [self showQueueMessageForEvent:queueEvent withPositions:positions];
        }
        
        if (error) {
            BFLogErr(@"handleQueueEvent ERROR: %@", error);
        }
    }];
}

- (void)handleQueuePenaltyEvent:(id<RAQueueEventPenaltyProtocol>)event {
    [RAAlertManager showAlertWithTitle:@"" message:event.message];
}

- (void)handleSurgeAreaEvent:(RAEventDataModel *)event {
    [self.surgeAreaManager handleSurgeAreaForEvent:event];
}

- (void)handleCategoryUpdateEvent:(id<RACarCategoryChangedEventProtocol>)event {
    switch (event.categoryChangeSource) {
        case MissedRequest:
            [self handleCarCategoryDisabledDueToMissedRides:event.missedCategories];
            break;
            
        case AdminEdit:
            [self handleCarCategoryChangedByAdmin];
            break;
            
        case Unknown:
            break;
    }
}

- (void)handleCarCategoryDisabledDueToMissedRides:(NSArray<NSString *>*)missedCategories {
    NSMutableSet<NSString *>*catLocalSelection  = [NSMutableSet setWithArray:[RASessionManager shared].currentSession.userCarTypes];
    NSSet<NSString *>*catDisabled = [NSSet setWithArray:missedCategories];
    [catLocalSelection minusSet:catDisabled];
    
    
    if (catLocalSelection.count <= 0) {
        [DriverManager updateDriverState:OfflineDriverState];
    } else {
        [[RASessionManager shared] saveUserCarTypes:catLocalSelection.allObjects];
    }
    
    if (catDisabled.count > 0) {
        [RAAlertManager showAlertWithDisabledCategory:catDisabled.allObjects andSource:MissedRequest];
    }
    
    [self.surgeAreaManager showCurrentSurgeAreas];
}

- (void)handleCarCategoryChangedByAdmin {
    NSString *alertTitle = [@"Car Categories updated by admin!" localized];
    NSSet<NSString *>*catPreviouslyAvailable = [NSSet setWithArray:[RASessionManager shared].currentSession.driver.selectedCar.carCategories];
    [[RASessionManager shared] reloadCurrentDriverWithCompletion:^(RADriverDataModel * _Nullable driver, NSError * _Nullable error) {
        if (!error) {
            NSSet<NSString *>*catAvailableForCar = [NSSet setWithArray:driver.selectedCar.carCategories];
            NSMutableSet *added = catAvailableForCar.mutableCopy;
            [added minusSet:catPreviouslyAvailable];
            
            NSMutableSet *deactivated = catPreviouslyAvailable.mutableCopy;
            [deactivated minusSet:catAvailableForCar];
            
            NSMutableString *message = [NSMutableString new];
            
            BOOL hasAdditions = added.count > 0;
            BOOL hasDeactivation = deactivated.count > 0;
            
            if (hasDeactivation) {
                [message appendFormat:[@"Car Category %@ disabled" localized], deactivated.allObjects.stringToCarCategories.titlesString];
                if (!hasAdditions) {
                    [message appendString:[@" by admin." localized]];
                }
            }
            
            if (hasAdditions) {
                if (message.length > 0) {
                    [message appendString:@"\n"];
                }
                [message appendFormat:[@"Car Category %@ activated by admin.\n\nPlease visit Menu -> Ride Request Type to enable" localized], added.allObjects.stringToCarCategories.titlesString];
            }

            if (message.length > 0) {
                [RAAlertManager showLocalNotificationWithTitle:alertTitle message:message andNotificationOption:[RAAlertNotificationOption notificationOptionWithState:StateAll andAlertActionTitle:[@"Ok" localized]]];
            }
            NSMutableSet *userCarTypes = [NSMutableSet setWithArray:[RASessionManager shared].currentSession.userCarTypes];
            [userCarTypes intersectSet:catAvailableForCar];
            [[RASessionManager shared] saveUserCarTypes:userCarTypes.allObjects];
            
        } else {
            NSString *message = [NSString stringWithFormat:[@"Please visit Menu -> Ride Request Type to review" localized]];
            [RAAlertManager showLocalNotificationWithTitle:alertTitle message:message andNotificationOption:[RAAlertNotificationOption notificationOptionWithState:StateAll andAlertActionTitle:[@"Ok" localized]]];
        }
    }];
}

- (void)handleRiderCommentUpdatedEvent:(RAEventDataModel *)event {
    self.rideDataModel.comment = event.ride.comment;
    if ([self canShowRiderComment] && [self.rideDataModel.comment isKindOfClass:[NSString class]]) {
        [[SoundManager sharedManager] playSound:SMSReceived];
        [self setRiderComment:self.rideDataModel.comment];
    }
}

- (void)handleCustomMessageEvent:(RAEventDataModel *)event {
    NSString *message = event.message;
    NSString *title   = event.title;
    if (message && [message isKindOfClass:[NSString class]]) {
        NSString *eventTitle = title ?: @"";
        [RAAlertManager showCustomMessageWithTitle:eventTitle andMessage:message];
    }
}

@end

@implementation LocationViewController (DriveUsageActionsTemporary)

- (void)didTapOnlineButton:(UIButton *)sender {
    __weak LocationViewController *weakself = self;
    [self showHUD];
    [[DriverManager shared] goOfflineWithCompletion:^(DriverState driverState, NSError * _Nullable error) {
        [weakself hideHUD];
        if (error) {
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive andShownOption:AllowNetworkError]];
        }
    }];
}

- (void)didTapOfflineButton:(UIButton *)sender {
    __weak LocationViewController *weakself = self;
    [self showHUD];
    [[DriverManager shared] goOnlineWithCompletion:^(DriverState driverState, NSError * _Nullable error) {
        [weakself hideHUD];
        if (error) {
            if (error.code == 412) {
                [RASessionManager shared].currentSession.driver.agreedToLegalTerms = NO;
                [weakself askConfirmationToReadNewTermsAndConditionsWithMessage:error.localizedRecoverySuggestion];
            } else {
                [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive andShownOption:AllowNetworkError]];
            }
        }
    }];
}

- (void)didTapArrived:(UIButton *)sender {
    CLLocation *pickupLocation = self.rideDataModel.startAddress.location;
    if (pickupLocation.isValid) {
        if ([[LocationService sharedService] isAllowedToPressArrivedBasedOnPickup:pickupLocation] ||
            [self.rideDataModel containsDriverType:DriverTypeDirectConnect]) {
            sender.enabled = NO;
            [[DriverManager shared] reachRiderWithCompletion:^{
                sender.enabled = YES;
            }];
        }
        else {
            NSString *message = @"Please drive closer to the pickup spot to start the trip.";
            [RAAlertManager showAlertWithTitle:[ConfigurationManager appName] message:message];
        }
    }
}

- (void)didTapStartTrip:(UIButton *)sender {
    sender.enabled = NO;
    [self showHUD];
    [[DriverManager shared] startTripWithCompletion:^{
        sender.enabled = YES;
        [self hideHUD];
    }];
}

- (void)didTapEndTrip:(UIButton *)sender {
    sender.enabled = NO;
    [self showHUD];
    [[DriverManager shared] endTripWithCompletion:^(RARideDataModel * _Nullable endedTrip, BOOL isCaching) {
        sender.enabled = YES;
        [self hideHUD];
        if (endedTrip) {
            [self completeEndRide:endedTrip];
        } else if (isCaching) {
            [self completeCachingRide];
        }
    }];
}

- (void)attemptToAcceptRideForRideRequestEvent:(id<RARideRequestProtocol>)event {
    [self showHUD];
    __weak LocationViewController *weakSelf = self;
    [[DriverManager shared] acceptTripFromRideRequestEvent:event withCompletion:^(NSError * _Nullable error) {
        [[RACallKitManager sharedManager] endCallWithCompletion:nil];
        [weakSelf hideHUD];
        if (error) {
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateAll andShownOption:Overlap|AllowNetworkError]];
            [weakSelf handleMissedRideForEvent:event];
        }
    }];
}

@end
