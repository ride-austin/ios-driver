//
//  EventsScenario.swift
//  RideDriver
//
//  Created by Theodore Gonzalez on 6/4/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

import Foundation

@objc public enum EventsScenario: Int, RawRepresentable {
    
    public typealias RawValue = String
    
    case NoEvents
    case IncomingRideWithComment
    case NewCommentOnTrip
    case UpdateCommentOnTrip
    case IncomingRideRequest
    case IncomingRideRequestPriority
    case IncomingRideRequestPerType
    case IncomingRideRequestPerScreen
    case IncomingRideRequestPerCategory
    case IncomingRideRequestWithoutDestination
    case UpgradeRequestAccepted
    case UpgradeRequestDeclinedByRider
    case AdminCanceledRide
    case DestinationChangedByRiderOnWay
    case DestinationChangedByRiderAfterDriverArrived
    case DestinationChangedByRiderWhileOnTrip
    case RiderLiveLocationUpdate
    case RiderLiveLocationExpire
    
    /// all scenarios should start with "EVENT_GENERATOR"
    ///
    /// events are returned by EventStubGenerator.modelsBasedOnScenario
    ///
    public var rawValue: RawValue {
        switch self {
        case .NoEvents:
            return "EVENT_GENERATOR_NoEvents"
        case .IncomingRideWithComment:
            return "EVENT_GENERATOR_IncomingRideWithComment"
        case .NewCommentOnTrip:
            return "EVENT_GENERATOR_NewCommentOnTrip"
        case .UpdateCommentOnTrip:
            return "EVENT_GENERATOR_UpdateCommentOnTrip"
        case .IncomingRideRequest:
            return "EVENT_GENERATOR_IncomingRideRequest"
        case .IncomingRideRequestPriority:
            return "EVENT_GENERATOR_IncomingRideRequestPriority"
        case .IncomingRideRequestPerType:
            return "EVENT_GENERATOR_IncomingRideRequestPerType"
        case .IncomingRideRequestPerScreen:
            return "EVENT_GENERATOR_IncomingRideRequestPerScreen"
        case .IncomingRideRequestPerCategory:
            return "EVENT_GENERATOR_IncomingRideRequestPerCategory"
        case .IncomingRideRequestWithoutDestination:
            return "EVENT_GENERATOR_IncomingRideRequestWithoutDestination"
        case .UpgradeRequestAccepted:
            return "EVENT_GENERATOR_UpgradeRequestAccepted"
        case .UpgradeRequestDeclinedByRider:
            return "EVENT_GENERATOR_UpgradeRequestDeclinedByRider"
        case .DestinationChangedByRiderOnWay:
            return "EVENT_GENERATOR_DestinationChangedByRiderOnWay"
        case .DestinationChangedByRiderAfterDriverArrived:
            return "EVENT_GENERATOR_DestinationChangedByRiderAfterDriverArrived"
        case .DestinationChangedByRiderWhileOnTrip:
            return "EVENT_GENERATOR_DestinationChangedByRiderWhileOnTrip"
        case .AdminCanceledRide:
            return "EVENT_GENERATOR_AdminCanceledRide"
        case .RiderLiveLocationUpdate:
            return "EVENT_GENERATOR_RiderLiveLocationUpdate"
        case .RiderLiveLocationExpire:
            return "EVENT_GENERATOR_RiderLiveLocationExpire"
        }
    }
    
    public init?(rawValue: RawValue) {
        switch rawValue {
        case "EVENT_GENERATOR_NoEvents":
            self = .NoEvents
        case "EVENT_GENERATOR_IncomingRideWithComment":
            self = .IncomingRideWithComment
        case "EVENT_GENERATOR_NewCommentOnTrip":
            self = .NewCommentOnTrip
        case "EVENT_GENERATOR_UpdateCommentOnTrip":
            self = .UpdateCommentOnTrip
        case "EVENT_GENERATOR_IncomingRideRequest":
            self = .IncomingRideRequest
        case "EVENT_GENERATOR_IncomingRideRequestPriority":
            self = .IncomingRideRequestPriority
        case "EVENT_GENERATOR_IncomingRideRequestPerType":
            self = .IncomingRideRequestPerType
        case "EVENT_GENERATOR_IncomingRideRequestPerScreen":
            self = .IncomingRideRequestPerScreen
        case "EVENT_GENERATOR_IncomingRideRequestPerCategory":
            self = .IncomingRideRequestPerCategory
        case "EVENT_GENERATOR_IncomingRideRequestWithoutDestination":
            self = .IncomingRideRequestWithoutDestination
        case "EVENT_GENERATOR_UpgradeRequestAccepted":
            self = .UpgradeRequestAccepted
        case "EVENT_GENERATOR_UpgradeRequestDeclinedByRider":
            self = .UpgradeRequestDeclinedByRider
        case "EVENT_GENERATOR_DestinationChangedByRiderOnWay":
            self = .DestinationChangedByRiderOnWay
        case "EVENT_GENERATOR_DestinationChangedByRiderAfterDriverArrived":
            self = .DestinationChangedByRiderAfterDriverArrived
        case "EVENT_GENERATOR_DestinationChangedByRiderWhileOnTrip":
            self = .DestinationChangedByRiderWhileOnTrip
        case "EVENT_GENERATOR_AdminCanceledRide":
            self = .AdminCanceledRide
        case "EVENT_GENERATOR_RiderLiveLocationUpdate":
            self = .RiderLiveLocationUpdate
        case "EVENT_GENERATOR_RiderLiveLocationExpire":
            self = .RiderLiveLocationExpire
         default:
            self = .NoEvents
        }
    }
}
