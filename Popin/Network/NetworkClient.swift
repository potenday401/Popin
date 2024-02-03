//
//  NetworkClient.swift
//  fourpin
//
//  Created by Jihaha kim on 2024/01/30.
//

import Foundation

protocol NetworkRequestable {
    func request<T: Decodable>(
        endpoint: URLRequestConfigurable,
        for type: T.Type,
        completionHandler: @escaping (Result<T, Error>) -> Void
    )
}

struct NetworkClient: NetworkRequestable {
    
    private let urlSession: URLSession
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    func request<T: Decodable>(
        endpoint: URLRequestConfigurable,
        for type: T.Type,
        completionHandler: @escaping (Result<T, Error>) -> Void
    ) {
        do {
            let urlRequest = try endpoint.asURLRequest()

            let dataTask = urlSession.dataTask(with: urlRequest) { data, response, error in
                guard let data = data else {
                    completionHandler(.failure(NSError(domain: "1", code: 1)))
                    return
                }

                guard error == nil else {
                    completionHandler(.failure(NSError(domain: "2", code: 2)))
                    return
                }
                
                do {
                    try validate(response: response)
                }
                catch {
                    completionHandler(.failure(error))
                }

                do {
                    let model = try JSONDecoder().decode(T.self, from: data)
                    completionHandler(.success(model))
                } catch {
                    completionHandler(.failure(NSError(domain: "3", code: 3)))
                }
            }

            dataTask.resume()
        } catch {
            completionHandler(.failure(NSError(domain: "4", code: 4)))
        }
    }
    
    private func validate(response: URLResponse?) throws {
        guard
            let response = response as? HTTPURLResponse,
            200..<300 ~= response.statusCode
        else {
            throw NSError(domain: "5", code: 5)
        }
    }
}
