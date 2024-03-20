//
//  LoginViewController.swift
//  Popin
//
//  Created by chamsol kim on 2/28/24.
//

import UIKit
import SnapKit

final class LoginViewController: BaseViewController {
    
    // MARK: - Interface
    
    var router: LoginRouter?
    
    // MARK: - UI
    
    private let navigationBar: PDSNavigationBar = {
        let navigationBar = PDSNavigationBar()
        navigationBar.titleView = UIImageView(image: UIImage(resource: .logo))
        return navigationBar
    }()
    
    private let appIconImageView = UIImageView(image: UIImage(resource: .appIcon))
    
    private lazy var emailInputField: PDSInputField = {
        let inputField = PDSInputField()
        inputField.delegate = self
        inputField.placeholder = Text.emailPlaceholder
        inputField.accessibilityIdentifier = "loginviewcontroller_email_inputfield"
        return inputField
    }()
    
    private lazy var passwordInputField: PDSInputField = {
        let inputField = PDSInputField()
        inputField.delegate = self
        inputField.placeholder = Text.passwordPlaceholder
        inputField.isSecureTextEntry = true
        inputField.accessibilityIdentifier = "loginviewcontroller_password_inputfield"
        return inputField
    }()
    
    private let inputStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        return stackView
    }()
    
    private let alertLabel: PDSAlertLabel = {
        let label = PDSAlertLabel()
        label.state = .error
        label.isHidden = true
        label.accessibilityIdentifier = "loginviewcontroller_alert_label"
        return label
    }()
    
    private lazy var signInButton: PDSButton = {
        let button = PDSButton(style: .primary)
        button.setTitle(Text.signInButtonTitle)
        button.addTarget(self, action: #selector(signInDidTap), for: .touchUpInside)
        button.accessibilityIdentifier = "loginviewcontroller_signin_button"
        return button
    }()
    
    private lazy var findPasswordButton: UIButton = {
        let button = makeButton(title: Text.findPasswordButtonTitle)
        button.addTarget(self, action: #selector(findPasswordDidTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var signUpButton: UIButton = {
        let button = makeButton(title: Text.signUpButtonTitle)
        button.addTarget(self, action: #selector(signUpDidTap), for: .touchUpInside)
        button.accessibilityIdentifier = "loginviewcontroller_signup_button"
        return button
    }()
    
    private func makeButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        return button
    }
    
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 24
        return stackView
    }()
    
    // MARK: - Property
    
    private let dependency: Dependency
    
    // MARK: - Initializer
    
    struct Dependency {
        let loginService: LoginService
        let tokenRepository: TokenRepository
    }
    
    init(dependency: Dependency) {
        self.dependency = dependency
        super.init()
    }
    
    // MARK: - Setup
    
    override func setUpUI() {
        shouldEndEditingIfTouchesEnded = true
        
        let appIconMargin: CGFloat = 74
        let inset: CGFloat = 16
        
        view.addSubview(navigationBar)
        navigationBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
        }
        
        view.addSubview(appIconImageView)
        appIconImageView.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom).offset(appIconMargin)
            make.centerX.equalToSuperview()
            make.size.equalTo(73)
        }
        
        view.addSubview(inputStackView)
        inputStackView.snp.makeConstraints { make in
            make.top.equalTo(appIconImageView.snp.bottom).offset(appIconMargin)
            make.leading.trailing.equalToSuperview().inset(inset)
        }
        [emailInputField, passwordInputField].forEach(inputStackView.addArrangedSubview(_:))
        
        view.addSubview(alertLabel)
        alertLabel.snp.makeConstraints { make in
            make.top.equalTo(inputStackView.snp.bottom).offset(38)
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(signInButton)
        signInButton.snp.makeConstraints { make in
            make.top.equalTo(alertLabel.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview().inset(inset)
        }
        
        view.addSubview(buttonStackView)
        buttonStackView.snp.makeConstraints { make in
            make.top.equalTo(signInButton.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
        }
        [findPasswordButton, signUpButton].forEach(buttonStackView.addArrangedSubview(_:))
    }
}

// MARK: - Action

private extension LoginViewController {
    
    @objc
    func signInDidTap() {
        guard let email = emailInputField.text,
              let password = passwordInputField.text
        else {
            return
        }
        
        login(email: email, password: password)
    }
    
    func login(email: String, password: String) {
        dependency.loginService
            .login(email: email, password: password) { [weak self] result in
                do {
                    let response = try result.get()
                    self?.dependency.tokenRepository.storeToken(
                        accessToken: response.accessToken,
                        refreshToken: response.refreshToken
                    )
                    self?.router?.routeToHome()
                } catch {
                    self?.alertLabel.text = error.localizedDescription
                    self?.alertLabel.isHidden = false
                }
            }
    }
    
    @objc
    func findPasswordDidTap() {
        print(#function)
    }
    
    @objc
    func signUpDidTap() {
        router?.routeToSignUp()
    }
}

// MARK: - PDSInputFieldDelegate

extension LoginViewController: PDSInputFieldDelegate {
    
    func inputFieldShouldBeginEditing(_ textField: PDSInputField) {
        alertLabel.isHidden = true
    }
}

// MARK: - Constant

private extension LoginViewController {
    
    enum Text {
        static let emailPlaceholder = "사용자 이메일"
        static let passwordPlaceholder = "비밀번호"
        static let signInButtonTitle = "로그인하기"
        static let findPasswordButtonTitle = "비밀번호 찾기"
        static let signUpButtonTitle = "회원가입하기"
    }
}
