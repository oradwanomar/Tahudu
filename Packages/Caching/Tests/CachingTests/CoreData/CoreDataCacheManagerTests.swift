@testable import Caching
import Foundation
import Testing

@Test func coreDataStoresAnyCodableModelAcrossInstances() throws {
    let url = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString)
        .appendingPathComponent("Caching.sqlite")
    defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }

    let first = try CoreDataCacheManager(storeURL: url)
    let model = CachedTestModel(name: "Listing", count: 2)
    try first.save(model, forKey: "model")

    let second = try CoreDataCacheManager(storeURL: url)
    #expect(try second.value(forKey: "model", as: CachedTestModel.self) == model)
    try second.remove(forKey: "model")
    #expect(try second.value(forKey: "model", as: CachedTestModel.self) == nil)
}

@Test func cacheManagerSelectsCoreDataStrategy() async throws {
    let url = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString)
        .appendingPathComponent("Caching.sqlite")
    defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }
    let manager = CacheManager(strategy: .data(storeURL: url))
    let value = CachedTestModel(name: "City", count: 1)
    let key = UUID().uuidString

    try await manager.save(value, forKey: key)
    let restored = try await manager.value(forKey: key, as: CachedTestModel.self)
    #expect(restored == value)
    try await manager.remove(forKey: key)
}

@Test func coreDataStrategyPersistsIndependentKeysAcrossManagers() async throws {
    let url = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString)
        .appendingPathComponent("Caching.sqlite")
    defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }

    let first = CacheManager(strategy: .data(storeURL: url))
    try await first.save(true, forKey: "favorite.one")
    try await first.save(false, forKey: "favorite.two")

    let second = CacheManager(strategy: .data(storeURL: url))
    #expect(try await second.value(forKey: "favorite.one", as: Bool.self) == true)
    #expect(try await second.value(forKey: "favorite.two", as: Bool.self) == false)

    try await second.remove(forKey: "favorite.one")
    let third = CacheManager(strategy: .data(storeURL: url))
    #expect(try await third.value(forKey: "favorite.one", as: Bool.self) == nil)
    #expect(try await third.value(forKey: "favorite.two", as: Bool.self) == false)
}

private struct CachedTestModel: Codable, Equatable {
    let name: String
    let count: Int
}
