//
//  PDSInputField+Preview.swift
//  Popin
//
//  Created by chamsol kim on 2/27/24.
//

import UIKit
import SnapKit

fileprivate final class PDSInputFieldPreviewViewController: UIViewController {
    
    let emailInputField: PDSInputField = {
        let inputField = PDSInputField()
        inputField.placeholder = "사용자 이메일"
        inputField.text = "daisy_com@khu.ac.kr"
        return inputField
    }()
    
    let passwordInputField: PDSInputField = {
        let inputField = PDSInputField()
        inputField.placeholder = "비밀번호"
        inputField.text = "12345678"
        inputField.isSecureTextEntry = true
        return inputField
    }()
    
    lazy var successButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Success", for: .normal)
        button.addTarget(self, action: #selector(buttonDidTap(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var failureButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Failure", for: .normal)
        button.addTarget(self, action: #selector(buttonDidTap(_:)), for: .touchUpInside)
        return button
    }()
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        return stackView
    }()
    
    let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .center
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
        
        view.addSubview(buttonStackView)
        buttonStackView.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }
        
        [emailInputField, passwordInputField].forEach(stackView.addArrangedSubview(_:))
        [successButton, failureButton].forEach(buttonStackView.addArrangedSubview(_:))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        view.endEditing(true)
    }
    
    @objc
    private func buttonDidTap(_ button: UIButton) {
        view.endEditing(true)
        emailInputField.isFailure = button == failureButton
    }
}

#Preview {
    PDSInputFieldPreviewViewController()
}
