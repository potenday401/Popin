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
        completion: @escaping (Result<Void, any Error>) -> Void
    ) {
        let request = PasswordRequest(query: [
            "email": email,
            "password": password,
            "confirmPassword": password,
            "verifiedToken": ""
        ])
        network.send(request) { result in
            switch result {
            case .success(let response):
                completion(.success(()))
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
