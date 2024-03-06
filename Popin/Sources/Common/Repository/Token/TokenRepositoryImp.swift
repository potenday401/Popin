//
//  TokenRepositoryImp.swift
//  Popin
//
//  Created by chamsol kim on 3/3/24.
//

import Foundation

final class TokenRepositoryImp: TokenRepository {
    
    // MARK: - Interface
    
    func storeToken(accessToken: String, refreshToken: String) {
        storage.storeAccessToken(accessToken)
        storage.storeRefreshToken(refreshToken)
    }
    
    // MARK: - Property
    
    private let storage: TokenStorage
    
    
    // MARK: - Initializer
    
    init(storage: TokenStorage) {
        self.storage = storage
    }
}
