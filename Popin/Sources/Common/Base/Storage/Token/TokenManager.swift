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
    
    var accessToken: String? {
        get {
            return keychain["accessToken"]
        }
        set {
            keychain["accessToken"] = newValue
        }
    }
    
    var refreshToken: String? {
        get {
            return keychain["refreshToken"]
        }
        set {
            keychain["refreshToken"] = newValue
        }
    }
    
    var Email: String? {
        get {
            return keychain["email"]
        }
        set {
            keychain["email"] = newValue
        }
    }
    
    private let accessTokenKey = "accessToken"
    private let refreshTokenKey = "refreshToken"
    private let emailKey = "email"
    
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
    
    func getEmail() -> String? {
        return keychain[emailKey]
    }
    
    func clearTokens() {
        keychain[accessTokenKey] = nil
        keychain[refreshTokenKey] = nil
    }
}

