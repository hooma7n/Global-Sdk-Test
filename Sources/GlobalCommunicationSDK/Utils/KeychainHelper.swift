//  Created by Devotel
//

import Foundation
import Security

enum KeychainHelper {
    static func save(value: String, for key: String) throws {
        let data = Data(value.utf8)
        let q: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecValueData: data,
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock
        ]
        SecItemDelete(q as CFDictionary)
        let status = SecItemAdd(q as CFDictionary, nil)
        guard status == errSecSuccess else { throw NSError(domain: "Keychain", code: Int(status)) }
    }

    static func load(key: String) throws -> String? {
        let q: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]
        var out: CFTypeRef?
        let status = SecItemCopyMatching(q as CFDictionary, &out)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess, let data = out as? Data else {
            throw NSError(domain: "Keychain", code: Int(status))
        }
        return String(data: data, encoding: .utf8)
    }

    static func delete(key: String) {
        let q: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ]
        SecItemDelete(q as CFDictionary)
    }
}
