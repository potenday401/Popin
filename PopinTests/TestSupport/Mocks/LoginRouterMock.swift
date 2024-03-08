//
//  LoginRouterMock.swift
//  PopinTests
//
//  Created by chamsol kim on 3/8/24.
//

import Foundation
@testable import Popin

final class LoginRouterMock: LoginRouter {
    
    var routeToHomeCallCount = 0
    func routeToHome() {
        routeToHomeCallCount += 1
    }
    
    var routeToSignUpCallCount = 0
    func routeToSignUp() {
        routeToSignUpCallCount += 1
    }
}
