import Foundation

enum BuildConfiguration: String {
    case debugProd
    case debugQA
    case releaseProd
    case releaseProdEnterprise
    case releaseQAEnterprise
    
    var avatar: Avatar {
        return .driver
    }
}

enum Avatar: String {
    case driver
    
    /// request parameter
    var parameter: String {
        return rawValue.uppercased()
    }
    
    var appName: String {
        switch self {
        case .driver:
            return "RideAustinDriver"
        }
    }
}

var Config: BuildConfiguration = {
    
    #if DEBUGQA
    return .debugQA
    #elseif DEBUG
    return .debugProd
    #elseif RELEASEQAENTERPRISE
    return .releaseQAEnterprise
    #elseif RELEASEENTERPRISE
    return .releaseProdEnterprise
    #else
    return .releaseProd
    #endif
    
}()

func executeInRelease(_ block: () -> Void) {
    switch Config {
    case .debugProd,
         .debugQA:
        break
    case
         .releaseProd,
         .releaseProdEnterprise,
         .releaseQAEnterprise:
        block()
    }
}

func executeInRealDevice(_ block: () -> Void) {
    #if targetEnvironment(simulator)
    #else
    block()
    #endif
}
