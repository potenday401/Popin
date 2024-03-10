//
//  VerificationServiceMock.swift
//  PopinTests
//
//  Created by chamsol kim on 3/10/24.
//

import Foundation
@testable import Popin

final class VerificationServiceMock: VerificationService {
    
    var requestVerificationCodeCallCount = 0
    var requestVerificationCodeEmail: String?
    func requestVerificationCode(email: String, completion: @escaping (Result<Void, any Error>) -> Void) {
        requestVerificationCodeCallCount += 1
        requestVerificationCodeEmail = email
    }
    
    var requestVerificationCallCount = 0
    var requestVerificationEmail: String?
    var requestVerificationCode: String?
    func requestVerification(email: String, verificationCode: String, completion: @escaping (Result<Void, any Error>) -> Void) {
        requestVerificationCallCount += 1
        requestVerificationEmail = email
        requestVerificationCode = verificationCode
    }
}
