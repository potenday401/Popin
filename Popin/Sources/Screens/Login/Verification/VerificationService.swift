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
}
