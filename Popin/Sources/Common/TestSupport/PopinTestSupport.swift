//
//  PopinTestSupport.swift
//  Popin
//
//  Created by chamsol kim on 3/8/24.
//

import Foundation

enum PopinTestSupport {
    
    static func setUpURLProtocol() {
        // Login
        let loginResponse = ["accessToken": "1234", "refreshToken": "asdf"]
        let loginResponseData = try! JSONSerialization.data(withJSONObject: loginResponse)
        
        // Verification
        let requestVerificationCodeResponse = ["message": "SUCCESS"]
        let requestVerificationCodeResponseData = try! JSONSerialization.data(
            withJSONObject: requestVerificationCodeResponse
        )
        
        let requestVerificationResponse = ["verifiedToken": "asdf"]
        let requestVerificationResponseData = try! JSONSerialization.data(
            withJSONObject: requestVerificationResponse
        )
        
        // Password
        let passwordResponse = ["message": "SUCCESS"]
        let passwordResponseData = try! JSONSerialization.data(
            withJSONObject: passwordResponse
        )
        
        PopinURLProtocolMock.successMock = [
            "/auth/login": (200, loginResponseData),
            "/member/pre-signup": (200, requestVerificationCodeResponseData),
            "/member/email-verification": (200, requestVerificationResponseData),
            "/member/signup": (200, passwordResponseData),
        ]
    }
}
