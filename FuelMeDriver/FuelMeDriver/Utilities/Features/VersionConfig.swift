import Foundation

struct VersionConfig: Codable, Equatable {
    let buildNumber: Int
    let minimumVersion: String
    let upgradeUrl: URL
    
    static var `defaults`: [String: Any] = [
        "buildNumber": 1,
        "minimumVersion": "1.0.0",
        "upgradeUrl": "https://rink.hockeyapp.net/apps/84e082dbcaf040b0acb3571894c0ad74"
    ]
    
    static var factory: Factory<VersionConfig> = Factory<VersionConfig>(dictionary: defaults)
}
