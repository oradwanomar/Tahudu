import Foundation

public enum CacheStrategy: Sendable {
    case data(storeURL: URL? = nil)
    case keychain(service: String)
    case userDefaults(suiteName: String? = nil, namespace: String = "default")
}
