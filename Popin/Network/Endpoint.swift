//
//  Endpoint.swift
//  fourpin
//
//  Created by Jihaha kim on 2024/01/30.
//

import Foundation

protocol URLRequestConfigurable {
    var urlString: String { get }
    var path: String? { get }
    var method: HTTPMethod { get }
    var headers: HTTPHeaders? { get }
    var encoder: ParameterEncodable { get }
    
    func asURLRequest() throws -> URLRequest
}

struct Endpoint { }
extension Endpoint {
    enum Pin {
        static let baseURL: String = "https://..."
    }
}

extension Endpoint.Pin: URLRequestConfigurable {
    
    var urlString: String {
        return Endpoint.Pin.baseURL
    }
    
    var path: String? {
        return "/"
    }
    
    var method: HTTPMethod {
        return .post
    }
    
    var headers: HTTPHeaders? {
        return ["Content-Type": "application/json"]
    }
    
    var encoder: ParameterEncodable {
        return URLEncoding()
    }
    
    var parameters: Parameters? {
        var commonParameters: Parameters = [
            "api_key": NetworkConstant.APIKey,
        ]
        
        return commonParameters
    }
    
    func asURLRequest() throws -> URLRequest {
        guard var url: URL = URL(string: self.urlString) else {
            throw JHNetworkError.invalidURLString
        }
        
        if let path { url.append(path: path) }
        
        var urlRequest: URLRequest = .init(url: url)
        urlRequest.httpMethod = self.method.uppercasedValue
        urlRequest.allHTTPHeaderFields = self.headers
        
        let encodedRequest = try encoder.encode(request: urlRequest, with: parameters)
        return encodedRequest
    }
}
