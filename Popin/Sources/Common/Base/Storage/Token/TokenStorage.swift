//
//  TokenStorage.swift
//  Popin
//
//  Created by chamsol kim on 3/2/24.
//

import Foundation

protocol TokenStorage {
    func storeAccessToken(_ token: String)
    var accessToken: String? { get }
    func deleteAccessToken()
    
    func storeRefreshToken(_ token: String)
    var refreshToken: String? { get }
    func deleteRefreshToken()
}
