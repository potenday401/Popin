//
//  AlamofireNetwork.swift
//  Popin
//
//  Created by chamsol kim on 3/3/24.
//

import Foundation
import Alamofire

final class AlamofireNetwork: Network {
    func upload(multipartFormData: @escaping (Alamofire.MultipartFormData) -> Void, to url: URL, method: HTTPMethod, headers: [String : String], encodingCompletion: @escaping (Result<Any, Error>) -> Void) {
        AF.upload(multipartFormData: multipartFormData, to: url, method: Alamofire.HTTPMethod(rawValue: method.rawValue), headers: HTTPHeaders(headers))
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let responseData):
                    encodingCompletion(.success(responseData))
                case .failure(let error):
                    encodingCompletion(.failure(error))
                }
            }
    }
    
    
    // MARK: - Interface
    func send<T>(
        _ request: T,
        completion: @escaping (Result<Response<T.Output>, Error>) -> Void
    ) where T : Request, T.Output : Decodable {
        session
            .request(
                request.endpoint,
                method: convert(from: request.method),
                parameters: request.query,
                encoder: JSONParameterEncoder.default
            )
            .validate(statusCode: 200..<500)
            .responseDecodable(of: T.Output.self) { dataResponse in
                switch dataResponse.result {
                case .success(let output):
                    let response = Response(
                        output: output,
                        statusCode: dataResponse.response?.statusCode ?? 200
                    )
                    completion(.success(response))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

    // MARK: - Property
    
    private let session: Session
    
    // MARK: - Initializer
    
    init(configuration: URLSessionConfiguration) {
        configuration.timeoutIntervalForRequest = 60
        configuration.timeoutIntervalForResource = 60
        self.session = Session(configuration: configuration)
    }
}

// MARK: - Converter

private extension AlamofireNetwork {
    
    func convert(from method: HTTPMethod) -> Alamofire.HTTPMethod {
        switch method {
        case .get:  .get
        case .post: .post
        }
    }
}
