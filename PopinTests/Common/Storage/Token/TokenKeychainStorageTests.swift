//
//  TokenKeychainStorageTests.swift
//  PopinTests
//
//  Created by chamsol kim on 3/2/24.
//

import XCTest
@testable import Popin

final class TokenKeychainStorageTests: XCTestCase {

    private var sut: TokenKeychainStorage!
    
    override func setUpWithError() throws {
        sut = TokenKeychainStorage()
    }

    override func tearDownWithError() throws {
        sut.deleteAccessToken()
        sut.deleteRefreshToken()
    }

    func testAddToken() throws {
        // given
        let accessToken = "1234"
        let refreshToken = "asdf"
        
        // when
        sut.storeAccessToken(accessToken)
        sut.storeRefreshToken(refreshToken)
        
        // then
        XCTAssertEqual(sut.accessToken, "1234")
        XCTAssertEqual(sut.refreshToken, "asdf")
    }
    
    func testDeleteToken() throws {
        // given
        let accessToken = "1234"
        let refreshToken = "asdf"
        sut.storeAccessToken(accessToken)
        sut.storeRefreshToken(refreshToken)
        
        // when
        sut.deleteAccessToken()
        sut.deleteRefreshToken()
        
        // then
        XCTAssertNil(sut.accessToken)
        XCTAssertNil(sut.refreshToken)
    }
    
    func testUpdateToken() {
        // given
        let accessToken = "1234"
        let refreshToken = "asdf"
        sut.storeAccessToken(accessToken)
        sut.storeRefreshToken(refreshToken)
        
        // when
        let otherAccessToken = "5678"
        let otherRefreshToken = "qwer"
        sut.storeAccessToken(otherAccessToken)
        sut.storeRefreshToken(otherRefreshToken)
        
        // then
        XCTAssertEqual(sut.accessToken, "5678")
        XCTAssertEqual(sut.refreshToken, "qwer")
    }
}
