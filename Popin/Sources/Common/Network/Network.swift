//
//  Network.swift
//  Popin
//
//  Created by chamsol kim on 3/3/24.
//

import Foundation

protocol Requestable {
    var urlRequest: URLRequest { get }
}

protocol EncodableRequest: Encodable, Requestable {}

protocol Network {
    func send<T: Request>(_ request: T, completion: @escaping (Result<Response<T.Output>, Error>) -> Void)
}

extension Network {
    func send<T: EncodableRequest>(_ request: T, completion: @escaping (Result<Data, Error>) -> Void) {
        var urlRequest = request.urlRequest
        
        do {
            let jsonData = try JSONEncoder().encode(request)
            urlRequest.httpBody = jsonData
            
            URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(CameraError.noData))
                    return
                }
                
                completion(.success(data))
            }.resume()
        } catch {
            completion(.failure(error))
        }
    }
}
