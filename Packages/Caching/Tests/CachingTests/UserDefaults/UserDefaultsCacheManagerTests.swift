@testable import Caching
import Foundation
import Testing

@Test func userDefaultsKeepsNamespacesSeparate() throws {
    let suite = "CachingTests.\(UUID().uuidString)"
    defer { UserDefaults(suiteName: suite)?.removePersistentDomain(forName: suite) }

    let first = try UserDefaultsCacheManager(suiteName: suite, namespace: "first")
    let second = try UserDefaultsCacheManager(suiteName: suite, namespace: "second")
    try first.save(true, forKey: "enabled")
    try second.save(false, forKey: "enabled")
    try first.removeAll()

    #expect(try first.value(forKey: "enabled", as: Bool.self) == nil)
    #expect(try second.value(forKey: "enabled", as: Bool.self) == false)
}

@Test func cacheManagerSelectsUserDefaultsStrategy() async throws {
    let suite = "CachingTests.\(UUID().uuidString)"
    defer { UserDefaults(suiteName: suite)?.removePersistentDomain(forName: suite) }
    let manager = CacheManager(strategy: .userDefaults(suiteName: suite, namespace: "settings"))

    try await manager.save(true, forKey: "enabled")
    #expect(try await manager.value(forKey: "enabled", as: Bool.self) == true)
    try await manager.removeAll()
    #expect(try await manager.value(forKey: "enabled", as: Bool.self) == nil)
}
