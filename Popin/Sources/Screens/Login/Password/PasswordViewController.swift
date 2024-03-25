//
//  PasswordViewController.swift
//  Popin
//
//  Created by chamsol kim on 3/12/24.
//

import UIKit
import SnapKit

protocol PasswordViewControllerDelegate: AnyObject {
    func passwordViewControllerDidTapBack(_ viewController: PasswordViewController)
    func passwordViewControllerDidSuccessRequest(_ viewController: PasswordViewController)
}

final class PasswordViewController: LoginDetailBaseViewController {
    
    // MARK: - Interface
    
    weak var delegate: PasswordViewControllerDelegate?
    
    // MARK: - UI
    
    private let passwordInputField: PDSInputField = {
        let inputField = PDSInputField()
        inputField.placeholder = Text.passwordInputFieldPlaceholder
        inputField.isSecureTextEntry = true
        return inputField
    }()
    private let confirmedPasswordInputField: PDSInputField = {
        let inputField = PDSInputField()
        inputField.placeholder = Text.confirmedPasswordInputFieldPlaceholder
        inputField.isSecureTextEntry = true
        return inputField
    }()
    private let alertLabel: PDSAlertLabel = {
        let label = PDSAlertLabel()
        label.text = Text.alertMessage
        return label
    }()
    private lazy var confirmButton: PDSButton = {
        let button = PDSButton(style: .secondary, isFullWidth: false)
        button.setTitle(Text.confirmButtonTitle)
        button.addTarget(self, action: #selector(confirmDidTap), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Property
    
    private let dependency: Dependency
    
    // MARK: - Initializer
    
    struct Dependency {
        let email: String
        let passwordService: PasswordService
    }
    
    init(title: String, numberOfStep: Int, step: Int, dependency: Dependency) {
        self.dependency = dependency
        super.init(title: title, numberOfStep: numberOfStep, step: step)
    }
    
    // MARK: - Setup
    
    override func setUpUI() {
        super.setUpUI()
        showsProgress = true
        
        navigationBar.leftItem = .init(
            image: UIImage(resource: .chevronLeft),
            target: self,
            action: #selector(backDidTap)
        )
        
        contentView.addSubview(passwordInputField)
        passwordInputField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(25)
            make.leading.trailing.equalToSuperview()
        }
        
        contentView.addSubview(confirmedPasswordInputField)
        confirmedPasswordInputField.snp.makeConstraints { make in
            make.top.equalTo(passwordInputField.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
        }
        
        contentView.addSubview(alertLabel)
        alertLabel.snp.makeConstraints { make in
            make.top.equalTo(confirmedPasswordInputField.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }
        
        contentView.addSubview(confirmButton)
        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(alertLabel.snp.bottom).offset(32)
            make.trailing.bottom.equalToSuperview()
        }
    }
}

// MARK: - Action

private extension PasswordViewController {
    
    @objc
    func backDidTap() {
        delegate?.passwordViewControllerDidTapBack(self)
    }
    
    @objc
    func confirmDidTap() {
        guard let password = confirmedPasswordInputField.text else {
            return
        }
        
        dependency.passwordService.requestUpdatePassword(email: dependency.email, password: password) { [weak self] result in
            guard let self else {
                return
            }
            
            do {
                try result.get()
                delegate?.passwordViewControllerDidSuccessRequest(self)
            } catch {
                // TODO: Error handling
            }
        }
    }
}

// MARK: - Constant

extension PasswordViewController {
    
    enum Text {
        static let passwordInputFieldPlaceholder = "사용자 비밀번호"
        static let confirmedPasswordInputFieldPlaceholder = "비밀번호 확인"
        static let alertMessage = "영문,숫자를 조합한 8~20자 이내의 비밀번호"
        static let confirmButtonTitle = "확인"
    }
}
