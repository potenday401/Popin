//
//  PopinURLProtocolMock.swift
//  Popin
//
//  Created by chamsol kim on 3/8/24.
//

import Foundation

typealias Path = String
typealias MockResponse = (statusCode: Int, data: Data?)

enum MockSessionError: Error {
    case notSupported
}

final class PopinURLProtocolMock: URLProtocol {
    
    // MARK: - Interface
    
    static var successMock = [Path: MockResponse]()
    static var failureErrors = [Path: Error]()
    
    // MARK: - Loading
    
    override class func canInit(with request: URLRequest) -> Bool {
        true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    override func startLoading() {
        defer {
            client?.urlProtocolDidFinishLoading(self)
        }
        
        guard let path = request.url?.path() else {
            client?.urlProtocol(self, didFailWithError: MockSessionError.notSupported)
            return
        }
        
        if let response = Self.successMock[path] {
            client?.urlProtocol(
                self,
                didReceive: HTTPURLResponse(
                    url: request.url!,
                    statusCode: response.statusCode,
                    httpVersion: nil,
                    headerFields: nil
                )!,
                cacheStoragePolicy: .notAllowed
            )
            response.data.map { client?.urlProtocol(self, didLoad: $0) }
            return
        }
        
        if let error = Self.failureErrors[path] {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }
    }
    
    override func stopLoading() {
        
    }
}
