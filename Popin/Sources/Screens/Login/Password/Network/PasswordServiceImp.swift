//
//  PasswordServiceImp.swift
//  Popin
//
//  Created by chamsol kim on 3/12/24.
//

import Foundation

final class PasswordServiceImp: PasswordService {
    
    // MARK: - Interface
    
    func requestUpdatePassword(
        email: String,
        password: String,
        confirmedPassword: String,
        completion: @escaping (Result<Void, any Error>) -> Void
    ) {
        guard validator.validatePassword(password) else {
            completion(.failure(PasswordError.invalidPassword))
            return
        }
        
        guard validator.validatePassword(confirmedPassword), password == confirmedPassword else {
            completion(.failure(PasswordError.confirmingError))
            return
        }
        
        let request = PasswordRequest(query: [
            "email": email,
            "password": password,
            "confirmPassword": password,
            "verifiedToken": ""
        ])
        network.send(request) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure:
                completion(.failure(PasswordError.serverError))
            }
        }
    }
    
    // MARK: - Property
    
    private let network: Network
    private let validator: EmailPasswordValidatorType
    
    // MARK: - Initializer
    
    init(network: Network, validator: EmailPasswordValidatorType) {
        self.network = network
        self.validator = validator
    }
}
