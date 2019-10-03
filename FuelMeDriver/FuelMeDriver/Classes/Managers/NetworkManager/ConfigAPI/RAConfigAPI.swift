//
//  RAConfigAPI.swift
//  RideDriver
//
//  Created by Theodore Gonzalez on 10/12/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

import Foundation
import RestKit
import Mantle

class RAConfigAPI: RABaseAPI {
    
    @objc static public func getVersionInfo(completion:((RAConfigAppDataModel?, Error?)->Void)?) {
        let path = kPathConfigsVersionInfo
        let params = ["avatarType"      :"DRIVER",
                      "platformType":"IOS"] as [String : Any]
        RKObjectManager.shared().httpClient.parameterEncoding = AFRKFormURLParameterEncoding
        RKObjectManager.shared().httpClient.getPath(path, parameters: params, success: { (operation, response) in
            let model = try? MTLJSONAdapter.model(of: RAConfigAppDataModel.self, fromJSONDictionary: response as! [AnyHashable : Any])
            completion?(model as? RAConfigAppDataModel, nil)
        }) { (operation, error) in
            let raError = error! as NSError
            completion?(nil, raError.filteredError(atReponse: operation?.response))
        }
    }
    
    @objc static public func getGlobalConfigurationAt(coordinate:CLLocationCoordinate2D, completion:((ConfigGlobal?, Error?)->Void)?) {
        getGlobalConfiguration(coordinate: coordinate, cityId: nil, completion:completion)
    }
    
    @objc static public func getGlobalConfigurationIn(cityId:NSNumber, completion:((ConfigGlobal?, Error?)->Void)?) {
        getGlobalConfiguration(coordinate: nil, cityId: cityId, completion: completion)
    }
    
    static public func getGlobalConfiguration(coordinate:CLLocationCoordinate2D?, cityId:NSNumber?, completion:((ConfigGlobal?, Error?)->Void)?) {
        let path = kPathConfigsDriverGlobal
        
        var params = [String:Any]()
        if let coordinate = coordinate {
            params["lat"] = coordinate.latitude
            params["lng"] = coordinate.longitude
        }
        
        if let cityId = cityId {
            params["cityId"] = cityId
        }
        
        RKObjectManager.shared().httpClient.parameterEncoding = AFRKFormURLParameterEncoding
        RKObjectManager.shared().httpClient.getPath(path, parameters: params, success: { (operation, response) in
            let model = try? MTLJSONAdapter.model(of: ConfigGlobal.self, fromJSONDictionary: response as! [AnyHashable : Any])
            completion?(model as? ConfigGlobal, nil)
        }) { (operation, error) in
            let raError = error! as NSError
            completion?(nil, raError.filteredError(atReponse: operation?.response))
        }
    }
    
}
