//
//  RideDriverEnums.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 6/15/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

typedef NS_ENUM(NSUInteger, NavigationApp) {
    WazeApp = 0,
    GoogleMapApp = 1,
    AppleMaps = 2
};

typedef NS_ENUM(NSUInteger, CallSetting){
    AcceptRequest = 0,
    OpenApp
};

typedef enum {
    FrontPhoto = 0,
    BackPhoto = 1,
    InsidePhoto = 2,
    TrunkPhoto = 3
} CarPhotoType;

typedef NS_ENUM(NSUInteger, DriverState) {
    /**
     *  @brief @p InvalidDriverState is the default state, not the state when we get errors or unknown events
     */
    InvalidDriverState          = 0,
    OfflineDriverState          = 1,
    AvailableDriverState        = 2,
    GoingToPickUpDriverState    = 3,
    ArrivingToPickUpDriverState = 4,
    OnTripDriverState           = 6,
    AcceptingRequest            = 7 //used to avoid showing mandatory alert when accepting request from callKit
};

/**
 *  According to server team, these are all the events available in Server 1.8
 *  REQUESTED,
 *  RIDER_CANCELLED,
 *  DRIVER_ASSIGNED,
 *  DRIVER_CANCELLED,
 *  DRIVER_REACHED,
 *  ACTIVE,                 //never used
 *  NO_AVAILABLE_DRIVER,    //for rider
 *  COMPLETED,
 *  ADMIN_CANCELLED,
 *  END_LOCATION_UPDATED,
 *  GO_OFFLINE,
 *  CUSTOM_MESSAGE,
 *  QUEUED_AREA_ENTERING,
 *  QUEUED_AREA_LEAVING,
 *  QUEUED_AREA_UPDATE
 *  QUEUED_AREA_LEAVING_INACTIVE
 *  QUEUED_AREA_LEAVING_RIDE
 *  QUEUED_AREA_LEAVING_PENALTY
 *  SURGE_AREA_UPDATE
 *  CAR_CATEGORY_CHANGE
 *  RATING_UPDATED
 *
 *  INACTIVE, RIDING, AVAILABLE are only for statuses when driver is ACTIVE
 */
typedef NS_ENUM(NSUInteger, DriverEventType) {
    /**
     *  @brief unsupported event
     */
    InvalidEventType,
    /**
     *  @brief these are unused
     */
    DriverAvailable,          //active driver status
    DriverRiding,             //active driver status
    DriverAssignedToRide,     //used in rider
    DriverReachedRider,       //used in rider
    NoAvailableDriverForRide, //used in rider
    RideActive,               //used in rider
    RideCompleted,            //used in rider
    /**
     * @brief called when server wants to send a ride request
     */
    HandShake,
    /**
     * @brief called when ride request is received
     */
    RideRequested,
    /**
     *  @brief called when rider's live location is updated
     */
    RiderLocationUpdated,
    /**
     *  @brief called when rider cancelled the ride
     */
    RiderCancelledRide,
    /**
     *  @brief called when admin cancelled the ride
     */
    AdminCancelledRide,
    /**
     *  @brief called when driver cancelled and he is eligible for cancellation fee, not called as of Server 2.6. Push notification is sent instead
     */
    DriverCancelledRide,
    /**
     *  @brief called when rider has updated his destination
     */
    RideDestinationUpdated,
    /**
     *  @brief called when driver is not on a trip and not sending location for x minutes
     */
    DriverInactive,
    /**
     *  @brief this will show an alert with message: event[@"message"]
     */
    CustomMessage,
    /**
     *  @brief called when driver is inside queue zone
     */
    QueueEntering,
    /**
     *  @brief called when position is changed in queue
     */
    QueueUpdate,
    /**
     *  @brief called when driver was removed from queue because he is outside queue zone
     */
    QueueLeavingArea,
    /**
     *  @brief called when driver was removed from queue because he is offline
     */
    QueueLeavingInactive,
    /**
     *  @brief called when driver was removed from queue because he got a ride
     */
    QueueLeavingInARide,
    /**
     *  @brief called when driver was removed and got a penalty
     */
    QueueLeavingPenalty,
    /**
     *  @brief called when surge area is changed
     */
    SurgeAreaChanged,
    /**
     *  @brief called when admin changes car category type
     *         called when 3 ride requests for a car category is missed by a car with more than 1 car categories selected
     */
    CarCategoryChanged,
    /**
     *  @brief called when driver type is updated such as female driver and chauffeur's permit
     */
    DriverTypeUpdate,
    /**
     *  @brief called after rider rates this driver
     */
    RatingUpdated,
    /**
     * @brief called when rider updates the ride comment.
     */
    RiderCommentUpdated,
    /**
     * @brief called when ride upgrade was accepted by rider.
     */
    RideUpgradeAccepted,
    /**
     * @brief called when rider upgrade was rejected by rider.
     */
    RideUpgradeRejected,
    /**
     *  @brief called when stacked ride is reassigned
     */
    RideStackedReassigned
};

typedef NS_ENUM(NSUInteger, InactiveEventSource) {
    InactiveSourceUnknown,
    TermsNotAccepted,
    MissedRides,
    NoLocationUpdate,
    CarTypesDeactivate
};

typedef NS_ENUM(NSUInteger, CarCategoryChangeSource) {
    Unknown       = -1,
    MissedRequest = 0,
    AdminEdit     = 1,
};

typedef NS_ENUM(NSUInteger, SurgeUpdateAction) {
    /**
     *  @brief do nothing
     */
    SurgeUpdateActionNone        = 0,
    /**
     *  @brief use `updatedSurge`
     */
    SurgeUpdateActionUseObject   = 1,
    /**
     *  @brief use request all surge areas
     */
    SurgeUpdateActionSendRequest = 2
};
