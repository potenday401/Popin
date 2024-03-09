//
//  VerificationError.swift
//  Popin
//
//  Created by chamsol kim on 3/8/24.
//

import Foundation

enum VerificationError: String, LocalizedError {
    case emptyEmail = "이메일 주소를 입력해주세요"
    case invalidEmailFormat = "유효하지 않는 메일 주소입니다"
    case userAlreadyExists = "가입된 이메일입니다"
    case serverError
}
