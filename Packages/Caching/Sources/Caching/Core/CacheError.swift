import Foundation

public enum CacheError: Error, Equatable {
    case invalidKey
    case invalidService
    case invalidStoredValue
    case unavailableDefaultsSuite(String)
    case keychainStatus(Int32)
}
