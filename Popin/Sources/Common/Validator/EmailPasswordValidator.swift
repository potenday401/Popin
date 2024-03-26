//
//  EmailPasswordValidator.swift
//  Popin
//
//  Created by chamsol kim on 3/4/24.
//

import Foundation

protocol EmailPasswordValidatorType {
    func validateEmail(_ email: String) -> Bool
    func validatePassword(_ password: String) -> Bool
}

struct EmailPasswordValidator: EmailPasswordValidatorType {
    
    // MARK: - Interface
    
    func validateEmail(_ email: String) -> Bool {
        email.wholeMatch(of: emailRegex) != nil
    }
    
    func validatePassword(_ password: String) -> Bool {
        password.wholeMatch(of: passwordRegex) != nil
    }
    
    // MARK: - Property
    
    private let emailRegex = /^(?=.{4,255}$)[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/
    private let passwordRegex = /^(?=.*[0-9])(?=.*[a-zA-Z])[A-Za-z\d~`!@#\$%^&*()_+\-=\{\[\}\]|\\:;"'<,>\.?\/]{8,20}$/
}
