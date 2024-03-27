//
//  LoginServiceImp.swift
//  Popin
//
//  Created by chamsol kim on 3/3/24.
//

import Foundation

final class LoginServiceImp: LoginService {
    
    // MARK: - Interface
    
    func login(
        email: String,
        password: String,
        completion: @escaping (Result<LoginResponse, Error>) -> Void
    ) {
        guard validator.validateEmail(email) else {
            completion(.failure(LoginError.invalidEmail))
            return
        }
        
        guard validator.validatePassword(password) else {
            completion(.failure(LoginError.invalidPassword))
            return
        }
        
        let request = LoginRequest(query: ["email": email, "password": password])
        network.send(request) { result in
            switch result {
            case .success(let response):
                guard response.statusCode == 200 else {
                    completion(.failure(LoginError.invalidAccount))
                    return
                }
                
                let loginResponse = LoginResponse(
                    accessToken: response.output.accessToken,
                    refreshToken: response.output.refreshToken
                )
                completion(.success(loginResponse))
            case .failure(let error):
                completion(.failure(LoginError.error))
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
