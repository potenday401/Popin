//
//  PDSInputField+Preview.swift
//  Popin
//
//  Created by chamsol kim on 2/27/24.
//

import UIKit
import SnapKit

fileprivate final class PDSInputFieldPreviewViewController: UIViewController {
    
    let emailInputField = PDSInputField()
    let passwordInputField = PDSInputField()
    lazy var stackView: UIStackView = {
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
        
        emailInputField.placeholder = "사용자 이메일"
        emailInputField.text = "kcsol1005@gmail.com"
        
        passwordInputField.placeholder = "비밀번호"
        passwordInputField.text = "12345678"
        passwordInputField.isSecureTextEntry = true
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(300)
        }
        
        [emailInputField, passwordInputField].forEach(stackView.addArrangedSubview(_:))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        emailInputField.endEditing(true)
        passwordInputField.endEditing(true)
    }
}

#Preview {
    PDSInputFieldPreviewViewController()
}
