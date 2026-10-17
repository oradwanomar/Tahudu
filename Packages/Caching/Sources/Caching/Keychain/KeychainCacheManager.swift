import Foundation
import Security

public final class KeychainCacheManager: CacheStorageProtocol {
    private let service: String
    private let client: any KeychainClient

    public convenience init(service: String) throws {
        try self.init(service: service, client: SystemKeychainClient())
    }

    init(service: String, client: any KeychainClient) throws {
        guard !service.isEmpty else { throw CacheError.invalidService }
        self.service = service
        self.client = client
    }

    public func save(_ data: Data, forKey key: String) throws {
        try validate(key)
        var item = itemQuery(forKey: key)
        item[kSecValueData] = data
        item[kSecAttrAccessible] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly

        let status = client.add(item)
        if status == errSecDuplicateItem {
            try check(client.update(itemQuery(forKey: key), attributes: [kSecValueData: data]))
        } else {
            try check(status)
        }
    }

    public func save(key: String, value: String) throws {
        try save(Data(value.utf8), forKey: key)
    }

    public func secret(forKey key: String) throws -> String? {
        guard let data = try data(forKey: key) else { return nil }
        guard let value = String(data: data, encoding: .utf8) else {
            throw CacheError.invalidStoredValue
        }
        return value
    }

    public func contains(_ key: String) throws -> Bool {
        try validate(key)
        var query = itemQuery(forKey: key)
        query[kSecMatchLimit] = kSecMatchLimitOne
        query[kSecReturnAttributes] = true

        let (status, _) = client.copy(query)
        if status == errSecItemNotFound {
            return false
        }
        try check(status)
        return true
    }

    public func data(forKey key: String) throws -> Data? {
        try validate(key)
        var query = itemQuery(forKey: key)
        query[kSecReturnData] = true
        query[kSecMatchLimit] = kSecMatchLimitOne

        let (status, result) = client.copy(query)
        if status == errSecItemNotFound {
            return nil
        }
        try check(status)
        guard let result else { throw CacheError.invalidStoredValue }
        return result
    }

    public func remove(forKey key: String) throws {
        try validate(key)
        let status = client.delete(itemQuery(forKey: key))
        if status != errSecItemNotFound {
            try check(status)
        }
    }

    public func removeAll() throws {
        let status = client.delete(serviceQuery())
        if status != errSecItemNotFound {
            try check(status)
        }
    }

    private func serviceQuery() -> [CFString: Any] {
        [kSecClass: kSecClassGenericPassword, kSecAttrService: service]
    }

    private func itemQuery(forKey key: String) -> [CFString: Any] {
        var query = serviceQuery()
        query[kSecAttrAccount] = key
        return query
    }

    private func validate(_ key: String) throws {
        guard !key.isEmpty else { throw CacheError.invalidKey }
    }

    private func check(_ status: OSStatus) throws {
        guard status == errSecSuccess else { throw CacheError.keychainStatus(status) }
    }
}
