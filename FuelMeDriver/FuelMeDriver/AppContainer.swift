import Foundation

final class AppContainer: NSObject {
    
    @objc lazy var featuresService = FeaturesService()
    
}
