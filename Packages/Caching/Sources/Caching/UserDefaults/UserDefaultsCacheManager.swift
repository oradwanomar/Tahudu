import Foundation

public final class UserDefaultsCacheManager: CacheStorageProtocol {
    private let defaults: UserDefaults
    private let prefix: String

    public init(suiteName: String? = nil, namespace: String = "default") throws {
        if let suiteName {
            guard let defaults = UserDefaults(suiteName: suiteName) else {
                throw CacheError.unavailableDefaultsSuite(suiteName)
            }
            self.defaults = defaults
        } else {
            defaults = .standard
        }
        prefix = "Caching.\(namespace)."
    }

    public func save(_ data: Data, forKey key: String) throws {
        try validate(key)
        defaults.set(data, forKey: prefix + key)
    }

    public func data(forKey key: String) throws -> Data? {
        try validate(key)
        return defaults.data(forKey: prefix + key)
    }

    public func remove(forKey key: String) throws {
        try validate(key)
        defaults.removeObject(forKey: prefix + key)
    }

    public func removeAll() throws {
        for key in defaults.dictionaryRepresentation().keys where key.hasPrefix(prefix) {
            defaults.removeObject(forKey: key)
        }
    }

    private func validate(_ key: String) throws {
        guard !key.isEmpty else { throw CacheError.invalidKey }
    }
}
