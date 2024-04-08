//
//  Keychain.swift
//  Keychain
//
//  https://www.advancedswift.com/secure-private-data-keychain-swift/
//

import Foundation

struct Keychain {
    static func save(_ secret: String, tag: String) throws {
        let query: [String: Any] = [
            kSecValueData as String: secret.data(using: .utf8)!,
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag.data(using: .utf8)!,
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecDuplicateItem {
            throw KeychainError.duplicate
        }
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
    
    static func update(_ secret: String, tag: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag.data(using: .utf8)!,
        ]
        let attributes: [String: Any] = [
            kSecValueData as String: secret.data(using: .utf8)!
        ]
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        guard status != errSecItemNotFound else {
            throw KeychainError.notFound
        }
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
    
    static func get(tag: String) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag.data(using: .utf8)!,
            kSecReturnData as String: true
        ]
        var ref: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &ref)
        guard status != errSecItemNotFound else {
            throw KeychainError.notFound
        }
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
        guard let data = ref as? Data else {
            throw KeychainError.invalidItemFormat
        }
        return String(decoding: data, as: UTF8.self)
    }
    
    static func delete(tag: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag.data(using: .utf8)!
        ]
        let status = SecItemDelete(query as CFDictionary)
        if status == errSecItemNotFound {
            throw KeychainError.notFound
        }
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
    
    enum KeychainError: Error {
        case notFound
        case duplicate
        case invalidItemFormat
        case unexpectedStatus(OSStatus)
    }
}
