//
//  LoginViewControllerTests.swift
//  PopinTests
//
//  Created by chamsol kim on 3/3/24.
//

import XCTest
@testable import Popin

final class LoginViewControllerTests: XCTestCase {
    
    private var sut: LoginViewController!
    private var loginService: LoginServiceMock!
    private var tokenRepository: TokenRepositoryMock!
    private var router: LoginRouterMock!
    
    override func setUpWithError() throws {
        loginService = LoginServiceMock()
        tokenRepository = TokenRepositoryMock()
        router = LoginRouterMock()
        sut = LoginViewController(
            dependency: .init(
                loginService: loginService,
                tokenRepository: tokenRepository
            )
        )
        sut.router = router
    }
    
    func testRequestLogin() {
        // given
        let email = "aaa@bbb.com"
        let password = "1234"
        
        sut.view.first(
            of: PDSInputField.self,
            with: "loginviewcontroller_email_inputfield"
        )?.text = email
        
        sut.view.first(
            of: PDSInputField.self,
            with: "loginviewcontroller_password_inputfield"
        )?.text = password
        
        // when
        sut.view.first(
            of: PDSButton.self,
            with: "loginviewcontroller_signin_button"
        )?.sendActions(for: .touchUpInside)
        
        // then
        XCTAssertEqual(loginService.loginCallCount, 1)
        XCTAssertEqual(loginService.loginEmail, email)
        XCTAssertEqual(loginService.loginPassword, password)
    }
    
    func testStoreToken() {
        // given
        let accessToken = "asdf"
        let refreshToken = "qwer"
        
        loginService.accessToken = accessToken
        loginService.refreshToken = refreshToken
        
        // when
        sut.view.first(
            of: PDSButton.self,
            with: "loginviewcontroller_signin_button"
        )?.sendActions(for: .touchUpInside)
        
        // then
        XCTAssertEqual(tokenRepository.storeTokenCallCount, 1)
        XCTAssertEqual(tokenRepository.accessToken, accessToken)
        XCTAssertEqual(tokenRepository.refreshToken, refreshToken)
    }
    
    func testSetErrorToAlertLabel() {
        // given
        let error = LoginError.invalidEmail
        loginService.loginError = error
        let alertLabel = sut.view.first(
            of: PDSAlertLabel.self,
            with: "loginviewcontroller_alert_label"
        )
        
        // when
        sut.view.first(
            of: PDSButton.self,
            with: "loginviewcontroller_signin_button"
        )?.sendActions(for: .touchUpInside)
        
        // then
        XCTAssertEqual(alertLabel?.text, error.localizedDescription)
    }
    
    func testAlertLabelVisibleIfFailure() {
        // given
        loginService.loginError = NSError(domain: "", code: 0)
        let alertLabel = sut.view.first(
            of: PDSAlertLabel.self,
            with: "loginviewcontroller_alert_label"
        )
        
        // when
        sut.view.first(
            of: PDSButton.self,
            with: "loginviewcontroller_signin_button"
        )?.sendActions(for: .touchUpInside)
        
        // then
        XCTAssertFalse(alertLabel!.isHidden)
    }
    
    func testRouteToHome() {
        // given
        
        
        // when
        sut.view.first(
            of: PDSButton.self,
            with: "loginviewcontroller_signin_button"
        )?.sendActions(for: .touchUpInside)
        
        // then
        XCTAssertEqual(router.routeToHomeCallCount, 1)
    }
    
    func testRouteToSignUp() {
        // when
        sut.view.first(
            of: UIButton.self,
            with: "loginviewcontroller_signup_button"
        )?.sendActions(for: .touchUpInside)
        
        // then
        XCTAssertEqual(router.routeToSignUpCallCount, 1)
    }
}
