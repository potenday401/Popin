//
//  PasswordError.swift
//  Popin
//
//  Created by chamsol kim on 3/12/24.
//

import Foundation

enum PasswordError: LocalizedError {
    case serverError
    
    var errorDescription: String? {
        switch self {
        case .serverError:
            "오류가 발생했어요. 다시 접속해주세요."
        }
    }
}
