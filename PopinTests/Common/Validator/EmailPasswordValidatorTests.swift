//
//  EmailPasswordValidatorTests.swift
//  PopinTests
//
//  Created by chamsol kim on 3/4/24.
//

import XCTest
@testable import Popin

final class EmailPasswordValidatorTests: XCTestCase {
    
    private let validEmailTestCases = [
        "example@example.com",
        "user123@example.co.uk",
        "user.name@example-domain.com",
    ]
    
    private let invalidEmailTestCases = [
        "example@example",
        "user@.com",
        "user@domain",
    ]
    
    private let validPasswordTestCase = [
        "Password123@",
        "StrongP@ssw0rd",
        "Pa$$w0rd123",
    ]
    
    private let invalidPasswordTestCase = [
        "weakpassword",
        "12345678",
        "Password",
    ]
    
    func testValidEmail() {
        let validator = EmailPasswordValidator()
        let results = validEmailTestCases.map(validator.validateEmail(_:))
        XCTAssertTrue(results.allSatisfy({ $0 }))
    }
    
    func testInvalidEmail() {
        let validator = EmailPasswordValidator()
        let results = invalidEmailTestCases.map(validator.validateEmail(_:))
        XCTAssertFalse(results.allSatisfy({ $0 }))
    }
    
    func testValidPassword() {
        let validator = EmailPasswordValidator()
        let results = validPasswordTestCase.map(validator.validatePassword(_:))
        XCTAssertTrue(results.allSatisfy({ $0 }))
    }
    
    func testInvalidPassword() {
        let validator = EmailPasswordValidator()
        let results = invalidPasswordTestCase.map(validator.validatePassword(_:))
        XCTAssertFalse(results.allSatisfy({ $0 }))
    }
}
