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
    case codeExpired = "입력시간이 초과되었습니다"
    case codeNotFound = "인증번호가 일치하지 않습니다"
    case serverError = "오류가 발생했어요. 다시 접속해주세요."
}
