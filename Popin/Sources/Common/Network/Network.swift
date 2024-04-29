//
//  Network.swift
//  Popin
//
//  Created by chamsol kim on 3/3/24.
//

import Foundation
import Alamofire

protocol Requestable {
    var urlRequest: URLRequest { get }
}

protocol EncodableRequest: Encodable, Requestable {}

protocol Network {
    func send<T: Request>(_ request: T, completion: @escaping (Result<Response<T.Output>, Error>) -> Void)
    func upload(
          multipartFormData: @escaping (MultipartFormData) -> Void,
          to url: URL,
          method: HTTPMethod,
          headers: [String: String],
          encodingCompletion: @escaping (Result<Any, Error>) -> Void
      )
//    func uploads(
//          multipartFormData: @escaping (MultipartFormData) -> Void,
//          title: String,
//          address: String,
//          latitude: Double,
//          longitude: Double,
//          memorizedAt: String,
//          to url: URL,
//          method: HTTPMethod,
//          headers: [String: String],
//          encodingCompletion: @escaping (Result<Any, Error>) -> Void
//      )
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
    
    func upload<T: Decodable>(
        multipartFormData: @escaping (MultipartFormData) -> Void,
        to url: URL,
        method: HTTPMethod,
        headers: [String: String],
        completion: @escaping (Result<Response<T>, Error>) -> Void
      ) {
          upload(
            multipartFormData: multipartFormData,
                 to: url, method: method, headers: headers) { (result: Result<Response<String>, Error>) in
          switch result {
          case .success(let urlRequest):
              AF.request(urlRequest as! URLRequestConvertible)
              .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let decodedResponse):
                    completion(.success(Response(output: decodedResponse, statusCode: response.response?.statusCode ?? 500)))
                case .failure(let error):
                  completion(.failure(error))
                }
              }
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }
//    func uploads<T: Decodable>(
//        multipartFormData: @escaping (MultipartFormData) -> Void,
//        to url: URL,
//        method: HTTPMethod,
//        headers: [String: String],
//        completion: @escaping (Result<Response<T>, Error>) -> Void
//      ) {
//        upload(multipartFormData: multipartFormData, to: url, method: method, headers: headers) { (result: Result<Response<String>, Error>) in
//          switch result {
//          case .success(let urlRequest):
//              AF.request(urlRequest as! URLRequestConvertible)
//              .responseDecodable(of: T.self) { response in
//                switch response.result {
//                case .success(let decodedResponse):
//                    completion(.success(Response(output: decodedResponse, statusCode: response.response?.statusCode ?? 500)))
//                case .failure(let error):
//                  completion(.failure(error))
//                }
//              }
//          case .failure(let error):
//            completion(.failure(error))
//          }
//        }
//      }
}
