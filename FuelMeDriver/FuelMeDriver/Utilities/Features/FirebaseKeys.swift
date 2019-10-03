import Foundation

enum FirebaseJSONKey: String, CaseIterable {
    
    case autoGoOfflineConfig
    case versionConfig
    
    static var defaults: [String: NSObject] = {
        var values = [String: NSObject]()
        for feature in FirebaseJSONKey.allCases {
           values[feature.rawValue] = feature.defaultValue
        }
        return values
    }()
    
    var defaultValue: NSObject {
        switch self {
        case .autoGoOfflineConfig:
            return NSDictionary(dictionary: AutoGoOfflineConfig.defaults)
            
        case .versionConfig:
            return NSDictionary(dictionary: VersionConfig.defaults)
        }
    }
    
}
