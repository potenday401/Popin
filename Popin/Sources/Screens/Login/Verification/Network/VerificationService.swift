//
//  VerificationService.swift
//  Popin
//
//  Created by chamsol kim on 3/8/24.
//

import Foundation

protocol VerificationService {
    func requestVerificationCode(
        email: String,
        completion: @escaping (
            Result<Void, Error>
        ) -> Void
    )
    func requestVerification(
        email: String,
        verificationCode: String,
        completion: @escaping (
            Result<Void, Error>
        ) -> Void
    )
}
