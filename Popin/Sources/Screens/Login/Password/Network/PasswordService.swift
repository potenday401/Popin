//
//  PasswordService.swift
//  Popin
//
//  Created by chamsol kim on 3/12/24.
//

import Foundation

protocol PasswordService {
    func requestUpdatePassword(
        email: String,
        password: String,
        confirmedPassword: String,
        completion: @escaping (
            Result<Void, Error>
        ) -> Void
    )
}
