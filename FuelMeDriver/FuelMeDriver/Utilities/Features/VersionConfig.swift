import Foundation

struct VersionConfig: Codable, Equatable {
    let buildNumber: Int
    let minimumVersion: String
    let upgradeUrl: URL
    
    static var `defaults`: [String: Any] = [
        "buildNumber": 1,
        "minimumVersion": "1.0.0",
        "upgradeUrl": "https://rideaustin.com/driver"
    ]
    
    static var factory: Factory<VersionConfig> = Factory<VersionConfig>(dictionary: defaults)
}
