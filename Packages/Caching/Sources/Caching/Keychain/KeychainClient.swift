import Foundation
import Security

protocol KeychainClient {
    func add(_ item: [CFString: Any]) -> OSStatus
    func update(_ query: [CFString: Any], attributes: [CFString: Any]) -> OSStatus
    func copy(_ query: [CFString: Any]) -> (OSStatus, Data?)
    func delete(_ query: [CFString: Any]) -> OSStatus
}

struct SystemKeychainClient: KeychainClient {
    func add(_ item: [CFString: Any]) -> OSStatus {
        SecItemAdd(item as CFDictionary, nil)
    }

    func update(_ query: [CFString: Any], attributes: [CFString: Any]) -> OSStatus {
        SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
    }

    func copy(_ query: [CFString: Any]) -> (OSStatus, Data?) {
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        return (status, result as? Data)
    }

    func delete(_ query: [CFString: Any]) -> OSStatus {
        SecItemDelete(query as CFDictionary)
    }
}
