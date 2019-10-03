//
//  RAQueuesAPI.swift
//  RideDriver
//
//  Created by Theodore Gonzalez on 10/1/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

import UIKit
import Mantle
import RestKit

class RAQueuesAPI: RABaseAPI {
    @objc static public func getQueues(cityId:Int, completion:@escaping (([QueueZone]?, Error?) -> Void)) {
        let path = kPathQueues
        let params = ["cityId" : cityId]
        
        RKObjectManager.shared().httpClient.getPath(path, parameters: params, success: { (operation, responseObject) in
            let models = try? MTLJSONAdapter.models(of: QueueZone.self, fromJSONArray: responseObject as! [Any])
            
            completion(models as? [QueueZone], nil)
        }) { (operation, error) in
            let raError = error! as NSError
            completion(nil, raError.filteredError(atReponse: operation?.response))
        }
    }
}
