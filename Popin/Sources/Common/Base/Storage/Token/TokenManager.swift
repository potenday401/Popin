//
//  TokenManager.swift
//  Popin
//
//  Created by Jihaha kim on 2024/06/18.
//

import Foundation
import KeychainAccess

class TokenManager {
    
    static let shared = TokenManager()
    
    private let keychain = Keychain(service: "com.popin.popin")
    
    private let accessTokenKey = "accessToken"
    private let refreshTokenKey = "refreshToken"
    
    private init() {}
    
    func saveTokens(accessToken: String, refreshToken: String) {
        keychain[accessTokenKey] = accessToken
        keychain[refreshTokenKey] = refreshToken
    }
    
    func getAccessToken() -> String? {
        return keychain[accessTokenKey]
    }
    
    func getRefreshToken() -> String? {
        return keychain[refreshTokenKey]
    }
    
    func clearTokens() {
        keychain[accessTokenKey] = nil
        keychain[refreshTokenKey] = nil
    }
}

