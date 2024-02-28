//
//  JHRequest.swift
//  fourpin
//
//  Created by Jihaha kim on 2024/01/30.
//

import Foundation


typealias HTTPHeaders = [String: String]

typealias Parameters = [String: Any]

enum HTTPMethod: String {
    case get
    case post
    case put
    case delete
    
    var uppercasedValue: String {
        return self.rawValue.uppercased()
    }
}
