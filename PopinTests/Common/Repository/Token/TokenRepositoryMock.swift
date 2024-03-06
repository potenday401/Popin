//
//  TokenRepositoryMock.swift
//  PopinTests
//
//  Created by chamsol kim on 3/3/24.
//

import Foundation
@testable import Popin

final class TokenRepositoryMock: TokenRepository {
    
    var storeTokenCallCount = 0
    var accessToken: String?
    var refreshToken: String?
    func storeToken(accessToken: String, refreshToken: String) {
        storeTokenCallCount += 1
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
}
