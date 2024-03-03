//
//  LoginserviceImp.swift
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
        let request = LoginRequest(email: email, password: password)
        network.send(request) { result in
            switch result {
            case .success(let response):
                let loginResponse = LoginResponse(
                    accessToken: response.output.accessToken,
                    refreshToken: response.output.refreshToken
                )
                completion(.success(loginResponse))
            case .failure(let error):
                completion(.failure(error))
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
