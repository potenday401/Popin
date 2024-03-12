//
//  RequestVerivicationViewControllerTests.swift
//  PopinTests
//
//  Created by chamsol kim on 3/10/24.
//

import XCTest
@testable import Popin

final class RequestVerivicationViewControllerTests: XCTestCase {
    
    private var sut: RequestVerificationViewController!
    private var verificationService: VerificationServiceMock!
    
    private let email = "aaa@bbb.com"
    
    override func setUpWithError() throws {
        verificationService = VerificationServiceMock()
        sut = RequestVerificationViewController(
            title: "인증번호를 확인하세요",
            numberOfStep: 4,
            step: 2,
            dependency: .init(
                email: email,
                verificationService: verificationService
            )
        )
    }
    
    func testRequestVerificationCode() throws {
        // given
        let verificationCode = "12345"
        sut.view.first(
            of: PDSVerificationCodeInputField.self,
            with: "requestverificationviewcontroller_email_inputfield"
        )?.code = verificationCode
        
        // when
        sut.view.first(
            of: PDSButton.self,
            with: "requestverificationviewcontroller_verification_button"
        )?.sendActions(for: .touchUpInside)
        
        // then
        XCTAssertEqual(verificationService.requestVerificationCallCount, 1)
        XCTAssertEqual(verificationService.requestVerificationEmail, email)
        XCTAssertEqual(verificationService.requestVerificationCode, verificationCode)
    }
    
}
