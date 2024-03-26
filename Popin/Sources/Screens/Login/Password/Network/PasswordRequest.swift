//
//  PasswordRequest.swift
//  Popin
//
//  Created by chamsol kim on 3/12/24.
//

import Foundation

struct PasswordRequest: Request {
    typealias Query = [String: String]
    typealias Output = PasswordResponse
    let endpoint: URL = Endpoint.Member.requestVerificationCode.url
    let method: HTTPMethod = .post
    let query: Query?
    let header: HTTPHeader = [:]
    
    init(
        email: String,
        password: String,
        confirmPassword: String,
        verifiedToken: String
    ) {
        query = [
            "email": email,
            "password": password,
            "confirmPassword": confirmPassword,
            "verifiedToken": verifiedToken
        ]
    }
    init(query: [String : String]?) {
        self.query = query
    }
}

struct PasswordResponse: Decodable {}
