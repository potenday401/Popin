//
//  VerificationRequest.swift
//  Popin
//
//  Created by chamsol kim on 3/10/24.
//

import Foundation

struct VerificationRequest: Request {
    typealias Query = [String: String]
    typealias Output = VerificationResponse
    
    let endpoint: URL = Endpoint.Member.requestVerification.url
    let method: HTTPMethod = .post
    let query: Query?
    let header: HTTPHeader = [:]
    
    init(query: Query?) {
        self.query = query
    }
}

struct VerificationResponse: Decodable {
    let verifiedToken: String
}
