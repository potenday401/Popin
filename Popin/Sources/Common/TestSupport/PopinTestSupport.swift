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
        
        PopinURLProtocolMock.successMock = [
            "/auth/login": (200, loginResponseData)
        ]
    }
}
