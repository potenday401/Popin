//
//  Request.swift
//  Popin
//
//  Created by chamsol kim on 3/3/24.
//

import Foundation

typealias HTTPHeader = [String: String]

protocol Request {
    associatedtype Output
    associatedtype Query: Encodable
    
    var endpoint: URL { get }
    var method: HTTPMethod { get }
    var query: Query? { get }
    var header: HTTPHeader { get }
    
    init(query: Query?)
}

enum RequestQueryType {
    case json
    case codable
}
