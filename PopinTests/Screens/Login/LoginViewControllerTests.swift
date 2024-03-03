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

    override func setUpWithError() throws {
        loginService = LoginServiceMock()
        tokenRepository = TokenRepositoryMock()
        sut = LoginViewController(
            dependency: .init(
                loginService: loginService,
                tokenRepository: tokenRepository
            )
        )
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
}
