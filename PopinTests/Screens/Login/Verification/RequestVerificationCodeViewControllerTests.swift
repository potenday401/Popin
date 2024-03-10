//
//  RequestVerificationCodeViewControllerTests.swift
//  PopinTests
//
//  Created by chamsol kim on 3/10/24.
//

import XCTest
@testable import Popin

final class RequestVerificationCodeViewControllerTests: XCTestCase {
    
    private var sut: RequestVerificationCodeViewController!
    private var verificationService: VerificationServiceMock!

    override func setUpWithError() throws {
        verificationService = VerificationServiceMock()
        sut = RequestVerificationCodeViewController(
            title: "이메일을 적어주세요.",
            dependency: .init(verificationService: verificationService)
        )
    }

    func testRequestVerificationCode() throws {
        // given
        let email = "aaa@bbb.com"
        sut.view.first(
            of: PDSInputField.self,
            with: "requestverificationcodeviewcontroller_email_inputfield"
        )?.text = email
        
        // when
        sut.view.first(
            of: PDSButton.self,
            with: "requestverificationcodeviewcontroller_verification_button"
        )?.sendActions(for: .touchUpInside)
        
        // then
        XCTAssertEqual(verificationService.requestVerificationCodeCallCount, 1)
        XCTAssertEqual(verificationService.requestVerificationCodeEmail, email)
    }
}
