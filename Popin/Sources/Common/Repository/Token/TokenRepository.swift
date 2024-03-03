//
//  TokenRepository.swift
//  Popin
//
//  Created by chamsol kim on 3/3/24.
//

import Foundation

protocol TokenRepository {
    func storeToken(accessToken: String, refreshToken: String)
}
