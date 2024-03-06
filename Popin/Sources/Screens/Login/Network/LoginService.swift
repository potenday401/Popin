//
//  LoginService.swift
//  Popin
//
//  Created by chamsol kim on 3/3/24.
//

import Foundation

protocol LoginService {
    func login(
        email: String,
        password: String,
        completion: @escaping (
            Result<LoginResponse, Error>
        ) -> Void
    )
}
