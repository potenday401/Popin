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
    
    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            "잘못된 이메일입니다."
        case .invalidPassword:
            "잘못된 비밀번호입니다."
        }
    }
}
