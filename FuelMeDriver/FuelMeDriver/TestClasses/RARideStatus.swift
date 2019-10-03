//
//  RARideStatus.swift
//  RideDriver
//
//  Created by Theodore Gonzalez on 6/5/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

import Foundation


@objc public enum RARideStatus: Int, RawRepresentable {
    case Unknown
    case Requested
    case DriverAssigned
    case DriverReached
    case Active
    case Completed
    case AdminCancelled
    case DriverCancelled
    case RiderCancelled

    public typealias RawValue = String
    
    public var rawValue: RawValue {
        switch self {
        case .Requested:
            return "REQUESTED"
        case .DriverAssigned:
            return "DRIVER_ASSIGNED"
        case .DriverReached:
            return "DRIVER_REACHED"
        case .Active:
            return "ACTIVE"
        case .Completed:
            return "COMPLETED"
        case .AdminCancelled:
            return "ADMIN_CANCELLED"
        case .DriverCancelled:
            return "DRIVER_CANCELLED"
        case .RiderCancelled:
            return "RIDER_CANCELLED"
        case .Unknown:
            return "NOT FROM SERVER"
        }
    }
    
    public init?(rawValue: RawValue) {
        switch rawValue {
        case "REQUESTED":
            self = .Requested
        case "DRIVER_ASSIGNED":
            self = .DriverAssigned
        case "DRIVER_REACHED":
            self = .DriverReached
        case "ACTIVE":
            self = .Active
        case "COMPLETED":
            self = .Completed
        case "ADMIN_CANCELLED":
            self = .AdminCancelled
        case "DRIVER_CANCELLED":
            self = .DriverCancelled
        case "RIDER_CANCELLED":
            self = .RiderCancelled
        default:
            self = .Unknown
        }
    }
}
