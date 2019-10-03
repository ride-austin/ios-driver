//
//  RAActiveDriversAPI.swift
//  RideDriver
//
//  Created by Theodore Gonzalez on 9/7/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

import UIKit
import RestKit
import Mantle

class RAActiveDriversAPI: RABaseAPI {
    @objc static public func getActiveDrivers(fromLocation:CLLocationCoordinate2D, cityId:Int, completion:(([RAActiveDriversCar]?, Error?) -> Void)?) {
        let path = kPathActiveDriver
        let params = ["latitude"  : fromLocation.latitude,
                      "longitude" : fromLocation.longitude,
                      "cityId"    : cityId,
                      "avatarType": "DRIVER",] as [String : Any]
        RKObjectManager.shared().httpClient.parameterEncoding = AFRKFormURLParameterEncoding
        RKObjectManager.shared().httpClient.getPath(path, parameters: params, success: { (operation, responseObject) in
            let models = try? MTLJSONAdapter.models(of: RAActiveDriversCar.self, fromJSONArray: responseObject as! [Any])
            completion?(models as? [RAActiveDriversCar], nil)
        }) { (operation, error) in
            let raError = error! as NSError
            completion?(nil, raError.filteredError(atReponse: operation?.response))
        }
    }
    
    @objc static public func postActiveDriver(latitude:Double, longitude:Double, cityId:Int, carCategories:String, driverType:DriverType = .unspecified, completion: ((Error?)->Void)?) {
        let path = kPathActiveDriver
        
        var params:[String : Any] =
            ["latitude"     : latitude,
             "longitude"    : longitude,
             "cityId"       : cityId,
             "carCategories": carCategories]
        
        switch driverType {
        case .directConnect:
            params["driverTypes"] = "DIRECT_CONNECT"
        case .femaleDriver:
            params["driverTypes"] = "WOMEN_ONLY"
        case .fingerPrinted:
            break
        case .unspecified:
            break
        }
        
        RKObjectManager.shared().httpClient.parameterEncoding = AFRKFormURLParameterEncoding
        RKObjectManager.shared().httpClient.postPath(path, parameters: params, success: { (operation, responseObject) in
            completion?(nil)
        }) { (operation, error) in
            let raError = error! as NSError
            completion?(raError.filteredError(atReponse: operation?.response))
        }
    }
    
    @objc static public func putActiveDriver(latitude:Double, longitude:Double, speed:Double, course:Double, carCategories:String, driverType:DriverType = .unspecified, completion:((Any?,Error?)->Void)?) {
        
        let sequence:time_t = time_t(NSDate.true().timeIntervalSince1970)
        var params: [String:Any] =
            ["latitude" : latitude,
             "longitude": longitude,
             "speed" : speed,
             "course" : course,
             "carCategories" : carCategories,
             "sequence" : sequence
            ]
        
        switch driverType {
        case .directConnect:
            params["driverTypes"] = "DIRECT_CONNECT"
        case .femaleDriver:
            params["driverTypes"] = "WOMEN_ONLY"
        case .fingerPrinted:
            break
        case .unspecified:
            break
        }
        
        let path = "\(kPathActiveDriver)?\(params.urlEncodedString())"
        RKObjectManager.shared().httpClient.parameterEncoding = AFRKFormURLParameterEncoding
        RKObjectManager.shared().httpClient.putPath(path, parameters:nil , success: { (operation, responseObject) in
            completion?(responseObject, nil)
        }) { (operation, error) in
            let raError = error! as NSError
            completion?(nil, raError.filteredError(atReponse: operation?.response))
        }
    }
    
    @objc static public func deleteActiveDriver(completion: ((Error?)-> Void)?) {
        let path = kPathActiveDriver
        RKObjectManager.shared().httpClient.parameterEncoding = AFRKFormURLParameterEncoding
        RKObjectManager.shared().httpClient.deletePath(path, parameters: nil, success: { (operation, responseObject) in
            completion?(nil)
        }) { (operation, error) in
            let raError = error! as NSError
            completion?(raError.filteredError(atReponse: operation?.response))
        }
    }
    
    /// when ONLINE,  server is returning 200 with activeDriver object
    /// when OFFLINE, server is returning 204 without object
    ///
    @objc static public func getActiveDriverCurrent(completion:((RAActiveDriver?,Error?)->Void)?) {
        RKObjectManager.shared().httpClient.parameterEncoding = AFRKFormURLParameterEncoding
        RKObjectManager.shared().httpClient.getPath(kPathActiveDriverCurrent, parameters: nil, success: { (operation, response) in
            let model = try?MTLJSONAdapter.model(of: RAActiveDriver.self, fromJSONDictionary: response as? [AnyHashable : Any])
            completion?(model as? RAActiveDriver, nil)
        }) { (operation, error) in
            let raError = error! as NSError
            completion?(nil, raError.filteredError(atReponse:operation?.response))
        }
    }
}



extension Dictionary where Key == String {
    func urlEncodedString() -> String {
        var parts = [String]()
        for key in self.keys {
            let param = "\(key)=\(String(describing: self[key]!))"
            parts.append(param)
        }
        return parts.joined(separator: "&")
    }
}
