//
//  NetworkManageError.swift
//  fourpin
//
//  Created by Jihaha kim on 2024/01/30.
//

import Foundation

enum NetworkError: Error {
    case noConnection
    case timeout
    case other(String)

    var localizedDescription: String {
        switch self {
        case .noConnection:
            return "No network connection."
        case .timeout:
            return "Request timed out."
        case .other(let description):
            return "Network error: \(description)"
        }
    }
}
