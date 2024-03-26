//
//  LoginError.swift
//  Popin
//
//  Created by chamsol kim on 3/4/24.
//

import Foundation

enum LoginError: LocalizedError {
    case invalidEmail
    case invalidPassword
    case invalidAccount
    case error
    
    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            "잘못된 이메일입니다."
        case .invalidPassword:
            "잘못된 비밀번호입니다."
        case .invalidAccount:
            "존재하지 않는 계정이에요."
        case .error:
            "오류가 발생했어요. 다시 시도해주세요."
        }
    }
}
