//
//  LoginViewController.swift
//  Popin
//
//  Created by chamsol kim on 2/28/24.
//

import UIKit
import SnapKit
import Alamofire

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
        guard let url = URL(string: "http://dev-api-popin.ap-northeast-2.elasticbeanstalk.com/users/login") else {
            print("Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            print("Error serializing JSON: \(error)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid HTTP response")
                return
            }
            
            if 200..<300 ~= httpResponse.statusCode {
                if let data = data {
                    do {
                        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                            print("유효한 JSON 형식이 아닙니다.")
                            return
                        }
                        print(json, "token check")
                        if let responseData = json["responseData"] as? [String: Any] {
                            if let accessToken = responseData["accessToken"] as? String,
                               let refreshToken = responseData["refreshToken"] as? String {
                                self.dependency.tokenRepository.storeToken(
                                    accessToken: accessToken,
                                    refreshToken: refreshToken
                                )
                                self.router?.routeToHome(accessToken: accessToken, refreshToken: refreshToken)
                            } else {
                                print("accessToken 또는 refreshToken을 찾을 수 없습니다.")
                            }
                        } else {
                            print("responseData가 유효하지 않습니다.")
                        }
                        let responseData = json["responseData"]
                    } catch {
                        print("Error parsing JSON: \(error)")
                    }
                } else {
                    print("No data received")
                }
            } else {
                print("HTTP status code: \(httpResponse.statusCode)")
            }
        }
        task.resume()
        //        login(email: email, password: password)
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
                    self?.router?.routeToHome(accessToken: response.accessToken, refreshToken: response.refreshToken)
                } catch {
                    self?.alertLabel.text = error.localizedDescription
                    self?.alertLabel.isHidden = false
                    switch error {
                    case LoginError.invalidEmail:
                        self?.emailInputField.isFailure = true
                    case LoginError.invalidPassword:
                        self?.passwordInputField.isFailure = true
                    case LoginError.invalidAccount:
                        self?.emailInputField.isFailure = true
                        self?.passwordInputField.isFailure = true
                    default:
                        return
                    }
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
        emailInputField.isFailure = false
        passwordInputField.isFailure = false
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
