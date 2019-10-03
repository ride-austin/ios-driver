import Foundation

@objc final class AutoGoOfflineConfig: NSObject, Codable {
    
    @objc let enabled: Bool
    @objc let backgroundWarningPeriod: Int
    @objc let backgroundMaximumPeriod: Int
    @objc let warningMessage: String
    @objc let offlineBackgroundMessage: String
    
    static var defaults: [String: Any] = [
        "enabled": true,
        "backgroundWarningPeriod": 10800,
        "backgroundMaximumPeriod": 10830,
        "warningMessage": "You've been away for a while.\nTap to STAY ONLINE",
        "offlineBackgroundMessage": "You are now offline"
    ]
    
    static var factory: Factory<AutoGoOfflineConfig> = Factory<AutoGoOfflineConfig>(dictionary: defaults)
    
}
