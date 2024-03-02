//
//  TokenKeychainStorage.swift
//  Popin
//
//  Created by chamsol kim on 3/2/24.
//

import Foundation
import Security

struct TokenKeychainStorage: TokenStorage {
    
    // MARK: - Interface
    
    var accessToken: String? {
        searchToken(forKey: accessTokenKey)
    }
    
    func storeAccessToken(_ token: String) {
        addToken(token, forKey: accessTokenKey)
    }
    
    func deleteAccessToken() {
        deleteToken(forKey: accessTokenKey)
    }
    
    var refreshToken: String? {
        searchToken(forKey: refreshTokenKey)
    }
    
    func storeRefreshToken(_ token: String) {
        addToken(token, forKey: refreshTokenKey)
    }
    
    func deleteRefreshToken() {
        deleteToken(forKey: refreshTokenKey)
    }
    
    // MARK: - Property
    
    private let accessTokenKey = "access_token_key"
    private let refreshTokenKey = "refresh_token_key"
}

// MARK: - Helper

private extension TokenKeychainStorage {
    
    func addToken(_ token: String, forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: token.data(using: .utf8)!,
        ]
        
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    func searchToken(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        guard status == errSecSuccess,
              let data = dataTypeRef as? Data
        else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func deleteToken(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}
