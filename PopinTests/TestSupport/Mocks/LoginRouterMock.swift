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
}
