//
//  EventStubGenerator.swift
//  RideDriver
//
//  Created by Theodore Gonzalez on 6/4/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

import Foundation
@objc final public class EventStubGenerator: NSObject {
    @objc public static let shared = EventStubGenerator()
    @objc public  var eventModels: Array<EventStubModel> = []
    private var currentRide: RARideDataModel?
    private var scenario: EventsScenario = .NoEvents
    fileprivate let launchDate = Date()
    
    private init(scenario: EventsScenario = .NoEvents, eventModels: Array<EventStubModel> = []) {
    }
    
    @objc public func loadArguments(_ arguments: Array<String>) {
        let filteredArray = arguments.filter { $0.hasPrefix("EVENT_GENERATOR") }
        if let scenarioRawValue = filteredArray.first {
            self.scenario = EventsScenario(rawValue: scenarioRawValue)!
        } else {
            self.scenario = .NoEvents
        }
        self.eventModels = modelsBasedOnScenario(self.scenario)
    }
    
    private func modelsBasedOnScenario(_ scenario:EventsScenario) ->  Array<EventStubModel>{
        //i would like to write the time, eventModel, rideData
        switch scenario {
        case .NoEvents:
            return [EventStubModel(seconds:0, launch:launchDate, model:nil)]
        case .IncomingRideWithComment:
            return self.stubsIncomingRideWithComment()
        case .NewCommentOnTrip:
            return self.stubsNewCommentOnTrip()
        case .UpdateCommentOnTrip:
            return self.stubsUpdateCommentOnTrip()
        case .IncomingRideRequest:
            return self.stubIncomingRideRequest()
        case .IncomingRideRequestPriority:
            return self.stubRideRequestAlternatePriority()
        case .IncomingRideRequestPerType:
            return self.stubRideRequestPerType()
        case .IncomingRideRequestPerScreen:
            return self.stubRideRequestPerScreen()
        case .IncomingRideRequestPerCategory:
            return self.stubRideRequestPerCategory()
        case .IncomingRideRequestWithoutDestination:
            return self.stubRideRequestWithoutDestination()
        case .UpgradeRequestAccepted:
            return self.stubRideRequestUpgradeAccepted()
        case .UpgradeRequestDeclinedByRider:
            return self.stubRideRequestUpgradeDeclinedByRider()
        case .DestinationChangedByRiderOnWay:
            return self.stubDestinationChangedByRiderOnWay()
        case .DestinationChangedByRiderAfterDriverArrived:
            return self.stubDestinationChangedByRiderAfterDriverArrived()
        case .DestinationChangedByRiderWhileOnTrip:
            return self.stubDestinationChangedByRiderWhileOnTrip()
        case .AdminCanceledRide:
            return self.stubAdminCancelledRideWhileOnWay()
        case .RiderLiveLocationUpdate:
            return self.stubRiderLiveLocationUpdate()
        case .RiderLiveLocationExpire:
            return self.stubRiderLiveLocationExpire()
        }
    }
    
    @objc public func updateRideStatus(status: RARideStatus) {
        switch status {
        case .Unknown:
            fallthrough
        case .DriverCancelled:
            fallthrough
        case .AdminCancelled:
            fallthrough
        case .RiderCancelled:
            self.currentRide = nil
        case .Requested:
            fallthrough
        case .DriverAssigned:
            fallthrough
        case .DriverReached:
            fallthrough
        case .Active:
            fallthrough
        case .Completed:
            self.currentRide?.status = status.rawValue
        }
    }
    
    @objc public func setUpgradeRequestedToCurrentRide(withSource source:String,andTarget target:String) {
        let rideRequestUpgrade = RideRequestUpgrade()
        rideRequestUpgrade?.target = "SUV"
        rideRequestUpgrade?.source = "REGULAR"
        rideRequestUpgrade?.status = .requested
        self.currentRide?.rideRequestUpgrade = rideRequestUpgrade
    }
    
    @objc public func willDispatchEvent(_ event:EventStubModel) {
        //update ride object
        if let ride = event.model?.ride  {
            self.currentRide = ride
        }
        self.eventModels.remove(event)
    }
    
    @objc public func currentRideDictionary() -> Dictionary<String, Any>? {
        return self.currentRide?.jsonObject() as? Dictionary<String, Any>
    }
    
}

//MARK: CommentUITest stub models
extension EventStubGenerator {
    static let testComment1 = "I’ll be waiting in front of a coffee shop, with two bags, wearing a yellow coat. I’d like you to help me with my bags, if it’s possible, please."
    static let testComment2 = "A new comment."
    
    fileprivate func stubsIncomingRideWithComment() -> Array<EventStubModel>{
        var stubs = [EventStubModel]()
        
        if let ride = RARideDataModel.ride(fromFileName: "RIDE_WITHOUT_COMMENT") {
            ride.comment = EventStubGenerator.testComment1
            let eventModel = RAEventDataModel.eventRequested(withRide: ride, modelId: 1)
            stubs.append(EventStubModel(seconds:25, launch:launchDate, model:eventModel))
        }
        return stubs
    }
    
    fileprivate func stubsNewCommentOnTrip() -> Array<EventStubModel>{
        var stubs = [EventStubModel]()
        
        if let ride = RARideDataModel.ride(fromFileName: "RIDE_WITHOUT_COMMENT") {
            let eventModel = RAEventDataModel.eventRequested(withRide: ride, modelId: 1)
            stubs.append(EventStubModel(seconds:25, launch:launchDate, model:eventModel))
        }
        if let ride = RARideDataModel.ride(fromFileName: "RIDE_WITHOUT_COMMENT") {
            ride.comment = EventStubGenerator.testComment2
            let eventModel = RAEventDataModel.eventRiderCommentUpdated(withRide: ride, modelId:1)
            stubs.append(EventStubModel(seconds:35, launch:launchDate, model:eventModel))
        }
        return stubs
    }
    
    fileprivate func stubsUpdateCommentOnTrip() -> Array<EventStubModel>{
        var stubs = [EventStubModel]()
        if let ride = RARideDataModel.ride(fromFileName: "RIDE_WITHOUT_COMMENT") {
            ride.comment = EventStubGenerator.testComment1
            let eventModel = RAEventDataModel.eventRequested(withRide: ride, modelId:1)
            stubs.append(EventStubModel(seconds:25, launch:launchDate, model:eventModel))
        }
        if let ride = RARideDataModel.ride(fromFileName: "RIDE_WITHOUT_COMMENT") {
            ride.comment = EventStubGenerator.testComment2
            let eventModel = RAEventDataModel.eventRiderCommentUpdated(withRide: ride, modelId:2)
            stubs.append(EventStubModel(seconds:34, launch:launchDate, model:eventModel))
        }
        return stubs
    }
    
}

//MARK: RideRequestUITest Stub Events
extension EventStubGenerator {
    
    fileprivate func stubIncomingRideRequest()->[EventStubModel] {
        var stubs = [EventStubModel]()
        if let ride = RARideDataModel.ride(fromFileName: "RIDE_WITHOUT_COMMENT") {
            let eventModel = RAEventDataModel.eventRequested(withRide: ride, modelId: 1)
            stubs.append(EventStubModel(seconds:25, launch:launchDate, model:eventModel))
        }
        return stubs
    }
    
    fileprivate func stubRideRequestAlternatePriority()->[EventStubModel] {
        var stubs = [EventStubModel]()
        if let ride = RARideDataModel.ride(fromFileName: "RIDE_WITHOUT_COMMENT") {
            var eventModel = RAEventDataModel.eventRequested(withRide: ride, modelId: 1)
            stubs.append(EventStubModel(seconds:25, launch:launchDate, model:eventModel))
            
            let ridePriority:RARideDataModel = ride.copy() as! RARideDataModel
            ridePriority.surgeFactor = 3.5
            eventModel = RAEventDataModel.eventRequested(withRide: ridePriority, modelId: 1)
            stubs.append(EventStubModel(seconds:35, launch:launchDate, model:eventModel))
        }
        return stubs
    }
    
    fileprivate func stubRideRequestPerType()->[EventStubModel] {
        var stubs = [EventStubModel]()
        if var ride = RARideDataModel.ride(fromFileName: "RIDE_WITHOUT_COMMENT") {
            //Normal RideRequest
            var eventModel = RAEventDataModel.eventRequested(withRide: ride, modelId: 1)
            stubs.append(EventStubModel(seconds:25, launch:launchDate, model:eventModel))
            
            //SurgeFactor Ride
            ride = ride.copy() as! RARideDataModel
            ride.surgeFactor = 3.5
            eventModel = RAEventDataModel.eventRequested(withRide: ride, modelId: 1)
            stubs.append(EventStubModel(seconds:35, launch:launchDate, model:eventModel))
            
            //Woman_only with surgeFactor
            ride = ride.copy() as! RARideDataModel
            ride.surgeFactor = 5.3
            ride.requestedDriverTypes = [ try! RADriverType(dictionary: ["name":"WOMEN_ONLY"])]
            eventModel = RAEventDataModel.eventRequested(withRide: ride, modelId: 1)
            stubs.append(EventStubModel(seconds:45, launch:launchDate, model:eventModel))
            
            //Woman_only without surgeFactor
            ride = ride.copy() as! RARideDataModel
            ride.surgeFactor = 1.0
            eventModel = RAEventDataModel.eventRequested(withRide: ride, modelId: 1)
            stubs.append(EventStubModel(seconds:55, launch:launchDate, model:eventModel))
        }
        return stubs
    }
    
    fileprivate func stubRideRequestPerScreen()->[EventStubModel] {
        var stubs = [EventStubModel]()
        if let ride = RARideDataModel.ride(fromFileName: "RIDE_WITHOUT_COMMENT") {
            //Map Screen
            let eventModel = RAEventDataModel.eventRequested(withRide: ride, modelId: 1)
            stubs.append(EventStubModel(seconds:25, launch:launchDate, model:eventModel))
            
            //Settings Screen
            stubs.append(EventStubModel(seconds:35, launch:launchDate, model:eventModel.copy() as? RAEventDataModel))
            
            //Earnings
            stubs.append(EventStubModel(seconds:45, launch:launchDate, model:eventModel.copy() as? RAEventDataModel))
            
            //RideRequest Type
            stubs.append(EventStubModel(seconds:55, launch:launchDate, model:eventModel.copy() as? RAEventDataModel))
            
            //Update Documents
            stubs.append(EventStubModel(seconds:65, launch:launchDate, model:eventModel.copy() as? RAEventDataModel))
        }
        return stubs
    }
    
    fileprivate func stubRideRequestPerCategory()->[EventStubModel] {
        var stubs = [EventStubModel]()
        if var ride = RARideDataModel.ride(fromFileName: "RIDE_WITHOUT_COMMENT") {
            //SUV
            ride.requestedCarType.carCategory = "SUV"
            ride.requestedCarType.title = "SUV"
            let eventModel = RAEventDataModel.eventRequested(withRide: ride, modelId: 1)
            stubs.append(EventStubModel(seconds:25, launch:launchDate, model:eventModel))
            
            //Premium
            ride = ride.copy() as! RARideDataModel
            ride.requestedCarType.carCategory = "PREMIUM"
            ride.requestedCarType.title = "PREMIUM"
            stubs.append(EventStubModel(seconds:35, launch:launchDate, model:eventModel))
            
            //Luxury
            ride = ride.copy() as! RARideDataModel
            ride.requestedCarType.carCategory = "LUXURY"
            ride.requestedCarType.title = "LUXURY"
            stubs.append(EventStubModel(seconds:45, launch:launchDate, model:eventModel))
        }
        return stubs
    }
    
}

//MARK: Upgrade Request

extension EventStubGenerator {

    fileprivate func stubRideRequestUpgradeAccepted()->[EventStubModel] {
        var stubs = [EventStubModel]()
        if let ride = RARideDataModel.ride(fromFileName: "RIDE_WITHOUT_COMMENT") {
            let rideRequestEventModel = RAEventDataModel.eventRequested(withRide: ride, modelId: 1)
            stubs.append(EventStubModel(seconds:25, launch:launchDate, model:rideRequestEventModel))
        }
        
        if let ride = RARideDataModel.ride(fromFileName: "RIDE_WITHOUT_COMMENT") {
            let rideRequestUpgrade = RideRequestUpgrade()
            rideRequestUpgrade?.target = "SUV"
            rideRequestUpgrade?.source = "REGULAR"
            rideRequestUpgrade?.status = .accepted
            ride.rideRequestUpgrade = rideRequestUpgrade
            let rideUpgradeAccepted = RAEventDataModel.eventUpgradeRequestAccepted(withRide: ride, modelId: 2)
            stubs.append(EventStubModel(seconds: 45, launch: launchDate, model: rideUpgradeAccepted))
        }
        
        return stubs
    }
    
    fileprivate func stubRideRequestUpgradeDeclinedByRider()->[EventStubModel] {
        var stubs = [EventStubModel]()
        if let ride = RARideDataModel.ride(fromFileName: "RIDE_WITHOUT_COMMENT") {
            let rideRequestEventModel = RAEventDataModel.eventRequested(withRide: ride, modelId: 1)
            stubs.append(EventStubModel(seconds:25, launch:launchDate, model:rideRequestEventModel))
        }
        
        if let ride = RARideDataModel.ride(fromFileName: "RIDE_WITHOUT_COMMENT") {
            let rideRequestUpgrade = RideRequestUpgrade()
            rideRequestUpgrade?.target = "SUV"
            rideRequestUpgrade?.source = "REGULAR"
            rideRequestUpgrade?.status = .declined
            ride.rideRequestUpgrade = rideRequestUpgrade
            let rideUpgradeDeclined = RAEventDataModel.eventUpgradeRequestDeclineByRider(withRide: ride, modelId: 2)
            stubs.append(EventStubModel(seconds: 45, launch: launchDate, model: rideUpgradeDeclined))
        }
        
        return stubs
    }
    
    fileprivate func stubAdminCancelledRideWhileOnWay()->[EventStubModel] {
        var stubs = [EventStubModel]()
        if let ride = RARideDataModel.ride(fromFileName: "RIDE_WITHOUT_COMMENT") {
            let rideRequestEventModel = RAEventDataModel.eventRequested(withRide: ride, modelId: 1)
            stubs.append(EventStubModel(seconds:25, launch:launchDate, model:rideRequestEventModel))
            
            let adminCancelEventModel = RAEventDataModel.eventAdminCancelledRide(ride, modelId: 2)
            stubs.append(EventStubModel(seconds: 36, launch: launchDate, model: adminCancelEventModel))
        }
        
        return stubs
    }
    
}

//MARK: Common on Trip

extension EventStubGenerator {
    
    fileprivate func stubRiderLiveLocationUpdate()->[EventStubModel] {
        var stubs = [EventStubModel]()
        if let ride = RARideDataModel.ride(fromFileName: "RIDE_WITHOUT_COMMENT") {
            let rideRequestEventModel = RAEventDataModel.eventRequested(withRide: ride, modelId: 1)
            stubs.append(EventStubModel(seconds:25, launch:launchDate, model:rideRequestEventModel))
            
            func appendLiveLocationWith(lat:Double, lng:Double, seconds:TimeInterval) {
                let modelId = NSNumber(value:stubs.count+1)
                let riderLocationUpdatedEventModel = RAEventDataModel.eventUpdateRiderLocation(withLatitude: lat as NSNumber, longitude: lng as NSNumber, modelId: modelId)
                stubs.append(EventStubModel(seconds:seconds, launch:launchDate, model:riderLocationUpdatedEventModel))
            }
            
            //Add RiderLiveLocation ~ Driver OnWay
            appendLiveLocationWith(lat: 30.41720472009257, lng: -97.750170193612575, seconds: 30)
            
            //Update RiderLiveLocation ~ Driver OnWay
            appendLiveLocationWith(lat: 30.417189107109984, lng: -97.75014404207468, seconds: 34)
            
            //Update RiderLiveLocation ~ Driver Arrived
            appendLiveLocationWith(lat: 30.41720472009257, lng: -97.750170193612575, seconds: 38)
            
            //Update RiderLiveLocation ~ Driver Arrived
            appendLiveLocationWith(lat: 30.417189107109984, lng: -97.75014404207468, seconds: 42)
            
            //Update RiderLiveLocation ~ Driver OnTrip ~ Just to check, app should not show
            appendLiveLocationWith(lat: 30.41720472009257, lng: -97.750170193612575, seconds: 46)
        }
        
        return stubs
    }
    
    fileprivate func stubRiderLiveLocationExpire()->[EventStubModel] {
        var stubs = [EventStubModel]()
        if let ride = RARideDataModel.ride(fromFileName: "RIDE_WITHOUT_COMMENT") {
            let rideRequestEventModel = RAEventDataModel.eventRequested(withRide: ride, modelId: 1)
            stubs.append(EventStubModel(seconds:25, launch:launchDate, model:rideRequestEventModel))
            
            func appendLiveLocationWith(lat:Double, lng:Double, seconds:TimeInterval) {
                let modelId = NSNumber(value:stubs.count+1)
                let riderLocationUpdatedEventModel = RAEventDataModel.eventUpdateRiderLocation(withLatitude: lat as NSNumber, longitude: lng as NSNumber, modelId: modelId)
                stubs.append(EventStubModel(seconds:seconds, launch:launchDate, model:riderLocationUpdatedEventModel))
            }
            
            //Add RiderLiveLocation ~ Driver OnWay
            appendLiveLocationWith(lat: 30.41720472009257, lng: -97.750170193612575, seconds: 30)
            
            //Update RiderLiveLocation ~ Driver Arrived
            appendLiveLocationWith(lat: 30.417189107109984, lng: -97.75014404207468, seconds: 39)
        }
        
        return stubs
    }
    
}

// MARK : On Way

extension EventStubGenerator {
    
    fileprivate func stubDestinationChangedByRiderOnWay()->[EventStubModel] {
        var stubs = [EventStubModel]()
        if let ride = RARideDataModel.ride(fromFileName: "RIDE_WITHOUT_COMMENT") {
            let rideRequestEventModel = RAEventDataModel.eventRequested(withRide: ride, modelId: 1)
            stubs.append(EventStubModel(seconds:25, launch:launchDate, model:rideRequestEventModel))
        }
        
        if let ride = RARideDataModel.ride(fromFileName: "RIDE_WITHOUT_COMMENT") {
            let endAddress = RARideAddressDataModel()
            endAddress?.setLocationBy(CLLocationCoordinate2DMake(30.277384, -97.745619))
            endAddress?.address = "1306-1398 Nueces St"
            
            ride.endAddress = endAddress
            
            
            let destinationChangeEventModel = RAEventDataModel.eventEndLocationUpdated(withRide: ride, modelId: 2)
            stubs.append(EventStubModel(seconds: 32, launch: launchDate, model: destinationChangeEventModel))
        }
        
        return stubs
    }

}

//MARK : Arrived

extension EventStubGenerator {
    
    fileprivate func stubDestinationChangedByRiderAfterDriverArrived()->[EventStubModel] {
        var stubs = [EventStubModel]()
        if let ride = RARideDataModel.ride(fromFileName: "RIDE_WITHOUT_COMMENT") {
            let rideRequestEventModel = RAEventDataModel.eventRequested(withRide: ride, modelId: 1)
            stubs.append(EventStubModel(seconds:25, launch:launchDate, model:rideRequestEventModel))
        }
        
        if let ride = RARideDataModel.ride(fromFileName: "RIDE_DESTINATION_UPDATE") {
            let destinationChangeEventModel = RAEventDataModel.eventEndLocationUpdated(withRide: ride, modelId: 2)
            stubs.append(EventStubModel(seconds: 35, launch: launchDate, model: destinationChangeEventModel))
        }
        
        return stubs
    }

}

//MARK: On Trip

extension EventStubGenerator {
    
    fileprivate func stubRideRequestWithoutDestination()->[EventStubModel] {
        var stubs = [EventStubModel]()
        if let ride = RARideDataModel.ride(fromFileName: "RIDE_WITHOUT_COMMENT") {
            ride.endAddress = nil
            let rideRequestEventModel = RAEventDataModel.eventRequested(withRide: ride, modelId: 1)
            stubs.append(EventStubModel(seconds:25, launch:launchDate, model:rideRequestEventModel))
        }
        return stubs
    }
    
    fileprivate func stubDestinationChangedByRiderWhileOnTrip()->[EventStubModel] {
        var stubs = [EventStubModel]()
        if let ride = RARideDataModel.ride(fromFileName: "RIDE_WITHOUT_COMMENT") {
            let rideRequestEventModel = RAEventDataModel.eventRequested(withRide: ride, modelId: 1)
            stubs.append(EventStubModel(seconds:25, launch:launchDate, model:rideRequestEventModel))
        }
        
        if let ride = RARideDataModel.ride(fromFileName: "RIDE_DESTINATION_UPDATE") {
            let destinationChangeEventModel = RAEventDataModel.eventEndLocationUpdated(withRide: ride, modelId: 2)
            stubs.append(EventStubModel(seconds: 33, launch: launchDate, model: destinationChangeEventModel))
        }
        
        return stubs
    }
    
}

//MARK: Helpers
extension Array where Element:Equatable {
    public mutating func remove(_ item:Element ) {
        var index = 0
        while index < self.count {
            if self[index] == item {
                self.remove(at: index)
            } else {
                index += 1
            }
        }
    }
    
    public func array( removing item:Element ) -> [Element] {
        var result = self
        result.remove( item )
        return result
    }
}
extension Array where Element:EventStubModel {
    mutating func repeatLastEventAfter(seconds: TimeInterval) {
        let stub = self.last!
        self.append(EventStubModel.eventStub(fromStub: stub, afterSeconds: seconds) as! Element)
    }
}
