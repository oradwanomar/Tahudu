import Foundation

public protocol CacheStorageProtocol {
    func save(_ data: Data, forKey key: String) throws
    func data(forKey key: String) throws -> Data?
    func remove(forKey key: String) throws
    func removeAll() throws
}

public extension CacheStorageProtocol {
    func save<Value: Encodable>(_ value: Value, forKey key: String) throws {
        try save(JSONEncoder().encode(value), forKey: key)
    }

    func value<Value: Decodable>(forKey key: String, as type: Value.Type) throws -> Value? {
        guard let data = try data(forKey: key) else { return nil }
        return try JSONDecoder().decode(type, from: data)
    }
}
