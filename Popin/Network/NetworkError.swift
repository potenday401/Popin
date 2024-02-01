//
//  NetworkError.swift
//  fourpin
//
//  Created by Jihaha kim on 2024/01/30.
//

import Foundation

enum JHNetworkError: Error {
    
    enum ParameterEncodingError: Error {
        case missingURL
        case invalidJSON
        case jsonEncodingFailed
    }
    
    case invalidURLString
    case endpointCongifureFailed
    case parameterEnocdingFailed(ParameterEncodingError)
}
