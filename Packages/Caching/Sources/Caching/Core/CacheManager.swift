import Foundation

public actor CacheManager: CacheManagerProtocol {
    private let strategy: CacheStrategy
    private var storage: (any CacheStorageProtocol)?

    public init(strategy: CacheStrategy = .data()) {
        self.strategy = strategy
    }

    public func save(_ data: Data, forKey key: String) throws {
        try storageForStrategy().save(data, forKey: key)
    }

    public func data(forKey key: String) throws -> Data? {
        try storageForStrategy().data(forKey: key)
    }

    public func remove(forKey key: String) throws {
        try storageForStrategy().remove(forKey: key)
    }

    public func removeAll() throws {
        try storageForStrategy().removeAll()
    }

    private func storageForStrategy() throws -> any CacheStorageProtocol {
        if let storage {
            return storage
        }

        let newStorage: any CacheStorageProtocol
        switch strategy {
        case let .data(storeURL):
            newStorage = try CoreDataCacheManager(storeURL: storeURL)
        case let .keychain(service):
            newStorage = try KeychainCacheManager(service: service)
        case let .userDefaults(suiteName, namespace):
            newStorage = try UserDefaultsCacheManager(suiteName: suiteName, namespace: namespace)
        }
        storage = newStorage
        return newStorage
    }
}
