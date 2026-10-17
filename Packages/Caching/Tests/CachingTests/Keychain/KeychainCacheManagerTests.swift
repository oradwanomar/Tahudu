@testable import Caching
import Foundation
import Security
import Testing

@Test func keychainManagerUpdatesAndDeletesScopedValues() throws {
    let client = InMemoryKeychainClient()
    let manager = try KeychainCacheManager(service: "test.service", client: client)

    try manager.save(key: "token", value: "first")
    try manager.save(key: "token", value: "second")
    #expect(try manager.secret(forKey: "token") == "second")
    #expect(try manager.contains("token"))
    #expect(client.lastService == "test.service")
    #expect(client.lastAccessibility == String(describing: kSecAttrAccessibleWhenUnlockedThisDeviceOnly))

    try manager.remove(forKey: "token")
    #expect(try manager.secret(forKey: "token") == nil)
    #expect(try !manager.contains("token"))

    try manager.save(key: "token", value: "third")
    try manager.removeAll()
    #expect(try manager.secret(forKey: "token") == nil)
}

#if os(iOS)
    @Test func keychainStoresAndRemovesSecrets() throws {
        let manager = try KeychainCacheManager(service: "CachingTests.\(UUID().uuidString)")
        defer { try? manager.removeAll() }

        do {
            try manager.save(key: "token", value: "secret")
        } catch CacheError.keychainStatus(-34018) {
            return
        }
        #expect(try manager.secret(forKey: "token") == "secret")
        try manager.remove(forKey: "token")
        #expect(try manager.secret(forKey: "token") == nil)
    }
#endif

private final class InMemoryKeychainClient: KeychainClient {
    private var values: [String: Data] = [:]
    private(set) var lastService: String?
    private(set) var lastAccessibility: String?

    func add(_ item: [CFString: Any]) -> OSStatus {
        guard let key = item[kSecAttrAccount] as? String,
              let data = item[kSecValueData] as? Data else { return errSecParam }
        lastService = item[kSecAttrService] as? String
        if let accessibility = item[kSecAttrAccessible] {
            lastAccessibility = String(describing: accessibility)
        }
        guard values[key] == nil else { return errSecDuplicateItem }
        values[key] = data
        return errSecSuccess
    }

    func update(_ query: [CFString: Any], attributes: [CFString: Any]) -> OSStatus {
        guard let key = query[kSecAttrAccount] as? String,
              let data = attributes[kSecValueData] as? Data else { return errSecParam }
        lastService = query[kSecAttrService] as? String
        guard values[key] != nil else { return errSecItemNotFound }
        values[key] = data
        return errSecSuccess
    }

    func copy(_ query: [CFString: Any]) -> (OSStatus, Data?) {
        guard let key = query[kSecAttrAccount] as? String else { return (errSecParam, nil) }
        lastService = query[kSecAttrService] as? String
        guard let data = values[key] else { return (errSecItemNotFound, nil) }
        return (errSecSuccess, data)
    }

    func delete(_ query: [CFString: Any]) -> OSStatus {
        lastService = query[kSecAttrService] as? String
        if let key = query[kSecAttrAccount] as? String {
            guard values.removeValue(forKey: key) != nil else { return errSecItemNotFound }
        } else {
            values.removeAll()
        }
        return errSecSuccess
    }
}
