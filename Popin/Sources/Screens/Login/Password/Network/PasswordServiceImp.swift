//
//  PasswordServiceImp.swift
//  Popin
//
//  Created by chamsol kim on 3/12/24.
//

import Foundation

final class PasswordServiceImp: PasswordService {
    func requestUpdatePassword(
        email: String,
        password: String,
        completion: @escaping (Result<PasswordResponse, any Error>) -> Void
    ) {
        guard validator.validatePassword(password) else {
            completion(.failure(PasswordError.invalidPassword))
            return
        }
        
        let request = PasswordRequest(query: [
            "email": email,
            "password": password,
        ])
        
        network.send(request) { result in
            switch result {
            case .success(let response):
                completion(.success(response.output))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private let network: Network
    private let validator: EmailPasswordValidatorType
    
    init(network: Network, validator: EmailPasswordValidatorType) {
        self.network = network
        self.validator = validator
    }
}
