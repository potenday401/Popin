//
//  LoginRequest.swift
//  Popin
//
//  Created by chamsol kim on 3/3/24.
//

import Foundation

struct LoginRequest: Request {
    typealias Output = LoginResponse
    let endpoint = Endpoint.Auth.login.url
    let method: HTTPMethod = .post
    let query: QueryItems
    let header: HTTPHeader = [:]
    
    init(email: String, password: String) {
        query = [
            "email": email,
            "password": password
        ]
    }
}

struct LoginResponse: Decodable {
    let accessToken: String
    let refreshToken: String
}
