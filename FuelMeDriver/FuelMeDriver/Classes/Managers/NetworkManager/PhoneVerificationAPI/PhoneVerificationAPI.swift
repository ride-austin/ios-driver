//
//  PhoneVerificationAPI.swift
//  RideDriver
//
//  Created by Theodore Gonzalez on 10/12/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

import Foundation
import RestKit
import Mantle

class PhoneVerificationAPI: RABaseAPI {
    @objc static public func postVerifyPhone(_ phone:String, completion:((String?,Error?)->Void)?) {
        let path = kPathPhoneVerificationRequestCode
        let params = ["phoneNumber" : phone]
        RKObjectManager.shared().httpClient.parameterEncoding = AFRKFormURLParameterEncoding
        RKObjectManager.shared().httpClient.postPath(path, parameters: params, success: { (operation, response) in
            if let response = response as? [String : String] {
                completion?(response["token"], nil)
            } else {
                let error = NSError(domain: "PhoneVerificationRequest", code: -1, userInfo: [NSLocalizedFailureReasonErrorKey : "PhoneVerificationVerify returned unexpected value"])
                completion?(nil, error)
            }
        }) { (operation, error) in
            let raError = error! as NSError
            completion?(nil, raError.filteredError(atReponse: operation?.response))
        }
    }
    
    @objc static public func postVerifyCode(_ code:String, token:String, completion:((Bool,Error?)->Void)?) {
        let path = kPathPhoneVerificationVerify
        let params = ["authToken" : token,
                      "code" : code]
        RKObjectManager.shared().httpClient.parameterEncoding = AFRKFormURLParameterEncoding
        RKObjectManager.shared().httpClient.postPath(path, parameters: params, success: { (operation, response) in
            completion?(true, nil)
        }) { (operation, error) in
            let raError = error! as NSError
            completion?(false, raError.filteredError(atReponse: operation?.response))
        }
    }
}
