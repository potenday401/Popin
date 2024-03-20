//
//  PDSInputField+Preview.swift
//  Popin
//
//  Created by chamsol kim on 2/27/24.
//

import UIKit
import SnapKit

fileprivate final class PDSInputFieldPreviewViewController: UIViewController {
    
    let emptyInputField: PDSInputField = {
        let inputField = PDSInputField()
        inputField.placeholder = "사용자 이메일"
        return inputField
    }()
    
    let emailInputField: PDSInputField = {
        let inputField = PDSInputField()
        inputField.placeholder = "사용자 이메일"
        inputField.text = "daisy_com@khu.ac.kr"
        return inputField
    }()
    
    let errorEmailInputField: PDSInputField = {
        let inputField = PDSInputField()
        inputField.placeholder = "사용자 이메일"
        inputField.text = "daisy_com@khu.ac.kr"
        inputField.isFailure = true
        return inputField
    }()
    
    let passwordInputField: PDSInputField = {
        let inputField = PDSInputField()
        inputField.placeholder = "비밀번호"
        inputField.text = "12345678"
        inputField.isSecureTextEntry = true
        return inputField
    }()
    
    let errorPasswordInputField: PDSInputField = {
        let inputField = PDSInputField()
        inputField.placeholder = "비밀번호"
        inputField.text = "12345678"
        inputField.isSecureTextEntry = true
        inputField.isFailure = true
        return inputField
    }()
    
    let fixedInputField: PDSInputField = {
        let inputField = PDSInputField()
        inputField.isFixed = true
        inputField.placeholder = "사용자 이메일"
        inputField.text = "daisy_com@khu.ac.kr"
        inputField.isFailure = true // fixed 상태에선 다른 상태로 변환되지 않아야 합니다.
        return inputField
    }()
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .gray600
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(300)
        }
        
        [emptyInputField,
         emailInputField,
         errorEmailInputField,
         passwordInputField,
         errorPasswordInputField,
         fixedInputField
        ].forEach(stackView.addArrangedSubview(_:))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        view.endEditing(true)
    }
}

#Preview {
    PDSInputFieldPreviewViewController()
}
