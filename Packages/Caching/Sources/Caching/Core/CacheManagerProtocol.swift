import Foundation

public protocol CacheManagerProtocol: Sendable {
    func save(_ data: Data, forKey key: String) async throws
    func data(forKey key: String) async throws -> Data?
    func remove(forKey key: String) async throws
    func removeAll() async throws
}

public extension CacheManagerProtocol {
    func save<Value: Encodable>(_ value: Value, forKey key: String) async throws {
        try await save(JSONEncoder().encode(value), forKey: key)
    }

    func value<Value: Decodable>(forKey key: String, as type: Value.Type) async throws -> Value? {
        guard let data = try await data(forKey: key) else { return nil }
        return try JSONDecoder().decode(type, from: data)
    }
}
