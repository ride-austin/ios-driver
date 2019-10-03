import Foundation

public enum FeatureError: CustomNSError {
    case failure(NSError?)
    case noFetchYet
    case throttled
    case unknownStatus
    
    public static var errorDomain: String {
        return String(describing: self)
    }
    
    public var errorCode: Int {
        switch self {
        case .failure(let error):
            return error?.code ?? 1
            
        case .noFetchYet:
            return 2
            
        case .throttled:
            return 3
            
        case .unknownStatus:
            return 4
        }
    }
    
    public var errorUserInfo: [String: Any] {
        switch self {
        case .failure(let error):
            guard let error = error as NSError? else { return [:] }
            return [
                "innerErrorCode": error.code,
                "innerErrorDomain": error.domain,
                "userInfo": error.userInfo
            ]
            
        default:
            return [:]
        }
    }
    
}
