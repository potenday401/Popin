//
//  VerificationServiceImp.swift
//  Popin
//
//  Created by chamsol kim on 3/8/24.
//

import Foundation

final class VerificationServiceImp: VerificationService {
    
    func requestVerificationCode(email: String, completion: @escaping (Result<Void, any Error>) -> Void) {
        let request = VerificationCodeRequest(email: email)
        network.send(request) { result in
            switch result {
            case .success(let response):
                switch response.statusCode {
                case 200..<300:
                    completion(.success(()))
                case 400:
                    completion(.failure(VerificationError.invalidEmailFormat))
                case 409:
                    completion(.failure(VerificationError.userAlreadyExists))
                default:
                    completion(.failure(VerificationError.serverError))
                }
            case .failure:
                completion(.failure(VerificationError.serverError))
            }
        }
    }
    
    func requestVerificationCode(email: String, verificationCode: String, completion: @escaping (Result<Void, any Error>) -> Void) {
        let request = VerificationRequest(email: email, verificationCode: verificationCode)
        network.send(request) { result in
            switch result {
            case .success(let response):
                switch response.statusCode {
                case 200..<300:
                    completion(.success(()))
                case 400:
                    completion(.failure(VerificationError.codeExpired))
                case 404:
                    completion(.failure(VerificationError.codeNotFound))
                default:
                    completion(.failure(VerificationError.serverError))
                }
            case .failure:
                completion(.failure(VerificationError.serverError))
            }
        }
    }
    
    // MARK: - Property
    
    private let network: Network
    
    // MARK: - Initializer
    
    init(network: Network) {
        self.network = network
    }
}
