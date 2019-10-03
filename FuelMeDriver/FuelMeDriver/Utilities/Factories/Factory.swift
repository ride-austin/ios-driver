import Foundation

/// https://github.com/mogstad/bankside
final class Factory<T: Decodable> {
    
    public typealias AttributeClosure = () -> Any
    
    private var attributes: [String: AttributeClosure] = [:]
    private let decoder = JSONDecoder()
    
    public init(dictionary: [String: Any]) {
        for (key, value) in dictionary {
            attr(key, value: value)
        }
    }
    
    @discardableResult
    public func dateDecodingStrategy(_ strategy: JSONDecoder.DateDecodingStrategy) -> Self {
        decoder.dateDecodingStrategy = strategy
        return self
    }
    
    @discardableResult
    public func attr(_ key: String, value: Any) -> Self {
        attributes[key] = { value }
        return self
    }
    
    @discardableResult
    public func attr(_ key: String, callback: @escaping AttributeClosure) -> Self {
        attributes[key] = callback
        return self
    }
    
    public func build(_ callback: (inout T) -> Void) -> T {
        do {
            var model = try decoder.decode(T.self, from: jsonData([:]))
            callback(&model)
            return model
        }
        catch let error {
            fatalError("build(attributes:) cannot decode model: \(error)")
        }
    }
    
    public func build(_ attributes: [String: Any] = [:]) -> T {
        do {
            let model = try decoder.decode(T.self, from: jsonData(attributes))
            return model
        }
        catch let error {
            fatalError("build(attributes:) cannot decode model: \(error)")
        }
    }
    
    public func jsonData(_ attributes: [String: Any] = [:]) -> Data {
        do {
            let attributes = self.attributes(attributes)
            let data = try JSONSerialization.data(withJSONObject: attributes, options: [])
            return data
        }
        catch {
            fatalError("jsonData(attributes:) cannot serialize attributes")
        }
    }
    
    public func attributes(_ attributes: [String: Any] = [:]) -> [String: Any] {
        var attributes = attributes
        
        for (key, value) in self.attributes where attributes[key] == nil {
            attributes[key] = value()
        }
        
        return attributes
    }
    
}
