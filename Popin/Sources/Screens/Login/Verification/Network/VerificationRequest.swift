//
//  VerificationRequest.swift
//  Popin
//
//  Created by chamsol kim on 3/10/24.
//

import Foundation

struct VerificationRequest: Request {
    typealias Output = VerificationResponse
    let endpoint: URL = Endpoint.Member.requestVerification.url
    let method: HTTPMethod = .post
    let query: QueryItems
    let header: HTTPHeader = [:]
    
    init(email: String, verificationCode: String) {
        query = ["email": email, "authCode": verificationCode]
    }
}

struct VerificationResponse: Decodable {
    let verifiedToken: String
}
