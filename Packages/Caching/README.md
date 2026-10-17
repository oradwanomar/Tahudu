# Caching

`CacheManager` selects a persistent store with `CacheStrategy`. Its asynchronous `CacheManagerProtocol` accepts raw `Data` and provides `Codable` helpers. Inject the protocol into repositories so storage can be replaced in tests.

| Strategy | Store | Intended use |
| --- | --- | --- |
| `.data()` | Core Data SQLite | Cached models and responses |
| `.keychain(service:)` | Keychain | Tokens and other secrets |
| `.userDefaults(suiteName:namespace:)` | UserDefaults | Small settings and flags |

```swift
let cache = CacheManager(strategy: .data())
try await cache.save(listings, forKey: "search.listings")
let saved = try await cache.value(forKey: "search.listings", as: [Listing].self)
```

Models stored in Core Data can be any `Codable` type. The manager encodes each value into a keyed Core Data record. A custom SQLite URL can be supplied with `.data(storeURL:)`, and `CoreDataCacheManager(inMemory: true)` is available for isolated tests.

Keychain entries are scoped to the supplied service. UserDefaults entries are scoped to the supplied namespace. `removeAll()` only removes entries within the selected store's scope.

```swift
let secrets = try KeychainCacheManager(service: "com.example.app")
try secrets.save(key: "accessToken", value: token)
let savedToken = try secrets.secret(forKey: "accessToken")
let hasToken = try secrets.contains("accessToken")
```

Keychain secrets use device only accessibility while the device is unlocked. Saving a value with an existing key updates that item.
