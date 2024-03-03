//
//  Request.swift
//  Popin
//
//  Created by chamsol kim on 3/3/24.
//

import Foundation

typealias QueryItems = [String: AnyHashable]
typealias HTTPHeader = [String: String]

protocol Request {
    associatedtype Output
    
    var endpoint: URL { get }
    var method: HTTPMethod { get }
    var query: QueryItems { get }
    var header: HTTPHeader { get }
}
