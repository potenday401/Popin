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
    
    let endpoint: URL = Endpoint.Member.signUp.url
    let method: HTTPMethod = .post
    let query: Query?
    let header: HTTPHeader = [:]
    
    init(query: Query?) {
        self.query = query
    }
}

struct PasswordResponse: Decodable {
    let accessToken: String
    let refreshToken: String
    
    private enum CodingKeys: String, CodingKey {
        case responseData
    }
    
    private enum ResponseDataKeys: String, CodingKey {
        case accessToken
        case refreshToken
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let responseDataContainer = try container.nestedContainer(keyedBy: ResponseDataKeys.self, forKey: .responseData)
        accessToken = try responseDataContainer.decode(String.self, forKey: .accessToken)
        refreshToken = try responseDataContainer.decode(String.self, forKey: .refreshToken)
    }
}

