//
//  PasswordError.swift
//  Popin
//
//  Created by chamsol kim on 3/12/24.
//

import Foundation

enum PasswordError: LocalizedError {
    case invalidPassword
    case confirmingError
    case serverError
    
    var errorDescription: String? {
        switch self {
        case .invalidPassword:
            "영문, 숫자를 조합한 8~20자 이내의 비밀번호"
        case .confirmingError:
            "비밀번호가 일치하지 않습니다."
        case .serverError:
            "오류가 발생했어요. 다시 접속해주세요."
        }
    }
}
