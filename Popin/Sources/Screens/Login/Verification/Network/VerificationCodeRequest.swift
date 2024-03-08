//
//  VerificationCodeRequest.swift
//  Popin
//
//  Created by chamsol kim on 3/8/24.
//

import Foundation

struct VerificationCodeRequest: Request {
    typealias Output = VerificationCodeResponse
    let endpoint: URL = Endpoint.Member.requestVerificationCode.url
    let method: HTTPMethod = .post
    let query: QueryItems
    let header: HTTPHeader = [:]
    
    init(email: String) {
        query = ["email": email]
    }
}

struct VerificationCodeResponse: Decodable {}
