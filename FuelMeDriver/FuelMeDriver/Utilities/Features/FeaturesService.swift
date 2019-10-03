import FirebaseRemoteConfig
import Foundation
import RxCocoa
import RxSwift

@objc final class FeaturesService: NSObject {
    
    @objc var autoGoOfflineValue: AutoGoOfflineConfig {
        return autoGoOfflineRelay.value
    }
    let autoGoOffline: Driver<AutoGoOfflineConfig>
    let versionConfig: Driver<VersionConfig>
    
    private let autoGoOfflineRelay: BehaviorRelay<AutoGoOfflineConfig>
    private let versionConfigRelay: BehaviorRelay<VersionConfig>
    private var remoteConfig: RemoteConfig
    
    private var expirationDuration: TimeInterval {
        switch Config {
        case .debugProd,
             .debugQA:
            return 10
            
        case .releaseProd,
             .releaseProdEnterprise,
             .releaseQAEnterprise:
            return 12 * 60
        }
    }
    
    override init() {
        remoteConfig = RemoteConfig.remoteConfig()
        remoteConfig.setDefaults(FirebaseJSONKey.defaults)
        
        autoGoOfflineRelay = BehaviorRelay(value: AutoGoOfflineConfig.factory.build())
        autoGoOffline = autoGoOfflineRelay.asDriver()
        
        versionConfigRelay = BehaviorRelay(value: VersionConfig.factory.build())
        versionConfig = versionConfigRelay.asDriver()
    }

    //    func fetch(completion: @escaping (FeatureError?) -> Void) {
    @objc func fetch() {
        RemoteConfig.remoteConfig().fetch(withExpirationDuration: expirationDuration) { [weak self] (status, error) in
            switch status {
            case .noFetchYet:
                //completion(.noFetchYet)
                // XTODO: report
                break
                
            case .success:
                RemoteConfig.remoteConfig().activate { (error) in
                    if error == nil {
                        self?.updateFeatures(from: RemoteConfig.remoteConfig())
                    }
                    // completion(nil)
                }

            case .failure:
                break //completion(.failure(error as NSError?))
                // XTODO: report
                
            case .throttled:
                break //completion(.throttled)
                // XTODO: report
            }
        }
    }
    
    private func updateFeatures(from remoteConfig: RemoteConfig) {
        for key in FirebaseJSONKey.allCases {
            switch key {
            case .autoGoOfflineConfig:
                updateRelay(
                    relay: autoGoOfflineRelay,
                    type: AutoGoOfflineConfig.self,
                    key: key
                )
                
            case .versionConfig:
                updateRelay(
                    relay: versionConfigRelay,
                    type: VersionConfig.self,
                    key: key
                )
            }
        }
    }
    
    private func updateRelay<T: Codable>(relay: BehaviorRelay<T>, type: T.Type, key: FirebaseJSONKey) {
        do {
            try relay.accept(FeaturesService.feature(
                key: key,
                type: type,
                from: remoteConfig
            ))
        }
        catch let error as DecodingError {
            assertionFailure("updateRelay.decodingError: \(error) key: \(key)")
            // XTODO: report decode error
        }
        catch let error {
            assertionFailure("updateRelay.jsonSerializationError: \(error) key: \(key)")
            // XTODO: report
        }
    }
    
    private static func feature<T: Codable>(key: FirebaseJSONKey, type: T.Type, from remoteConfig: RemoteConfig) throws -> T {
        let configValue = remoteConfig.configValue(forKey: key.rawValue)
        let model = try JSONDecoder().decode(type, from: configValue.dataValue)
        return model
    }
    
}
