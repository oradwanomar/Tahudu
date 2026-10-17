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

private struct CachedTestModel: Codable, Equatable {
    let name: String
    let count: Int
}
