//
//  LoginServiceMock.swift
//  PopinTests
//
//  Created by chamsol kim on 3/3/24.
//

import Foundation
@testable import Popin

final class LoginServiceMock: LoginService {
    
    var loginCallCount = 0
    var loginEmail: String?
    var loginPassword: String?
    
    var accessToken = ""
    var refreshToken = ""
    
    var loginError: Error?
    
    func login(email: String, password: String, completion: @escaping (Result<LoginResponse, Error>) -> Void) {
        loginCallCount += 1
        loginEmail = email
        loginPassword = password
        
        if let loginError {
            return completion(.failure(loginError))
        }
        
        let response = LoginResponse(accessToken: accessToken, refreshToken: refreshToken)
        completion(.success(response))
    }
}
