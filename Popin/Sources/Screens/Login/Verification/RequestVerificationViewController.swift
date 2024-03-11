//
//  RequestVerificationViewController.swift
//  Popin
//
//  Created by chamsol kim on 3/10/24.
//

import UIKit
import SnapKit

protocol RequestVerificationViewControllerDelegate: AnyObject {
    func requestVerificationViewControllerBackDidTap(_ viewController: RequestVerificationViewController)
}

final class RequestVerificationViewController: LoginDetailBaseViewController {
    
    // MARK: - Interface
    
    weak var delegate: RequestVerificationViewControllerDelegate?
    
    // MARK: - UI
    
    private let verificationCodeInputField: PDSVerificationCodeInputField = {
        let inputField = PDSVerificationCodeInputField(numberOfDigits: 5)
        inputField.accessibilityIdentifier = "requestverificationviewcontroller_email_inputfield"
        return inputField
    }()
    private lazy var verificationButton: PDSButton = {
        let button = PDSButton(style: .primary)
        button.setTitle(Text.verificationButtonTitle)
        button.addTarget(self, action: #selector(verifyDidTap), for: .touchUpInside)
        button.accessibilityIdentifier = "requestverificationviewcontroller_verification_button"
        return button
    }()
    
    // MARK: - Property
    
    private let dependency: Dependency
    
    // MARK: - Initializer
    
    struct Dependency {
        let email: String
        let verificationService: VerificationService
    }
    
    init(title: String, numberOfStep: Int, step: Int, dependency: Dependency) {
        self.dependency = dependency
        super.init(title: title, numberOfStep: numberOfStep, step: step)
    }
    
    // MARK: - Setup
    
    override func setUpUI() {
        super.setUpUI()
        
        navigationBar.leftItem = .init(
            image: UIImage(resource: .chevronLeft),
            target: self,
            action: #selector(backDidTap)
        )
        
        contentView.addSubview(verificationCodeInputField)
        verificationCodeInputField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(42)
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(verificationButton)
        verificationButton.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(Metric.inset)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-Metric.inset)
        }
    }
    
    // MARK: - Keyboard
    
    override func keyboardWillShowNotification(_ userInfo: KeyboardNotificationUserInfo) {
        updateVerificationButtonLayout(
            withDuration: userInfo.animationDuration,
            options: userInfo.animationCurveOptions,
            with: -userInfo.endFrame.height
        )
    }
    
    override func keyboardWillHideNotification(_ userInfo: KeyboardNotificationUserInfo) {
        updateVerificationButtonLayout(
            withDuration: userInfo.animationDuration,
            options: userInfo.animationCurveOptions,
            with: -Metric.inset
        )
    }
    
    private func updateVerificationButtonLayout(
        withDuration duration: TimeInterval,
        options: UIView.AnimationOptions,
        with offset: CGFloat
    ) {
        UIView.animate(withDuration: duration, delay: 0, options: options) {
            self.verificationButton.snp.updateConstraints { make in
                make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(offset)
            }
        }
        view.layoutIfNeeded()
    }
}

// MARK: - Action

private extension RequestVerificationViewController {
    
    @objc
    func backDidTap() {
        delegate?.requestVerificationViewControllerBackDidTap(self)
    }
    
    @objc
    func verifyDidTap() {
        guard let verificationCode = verificationCodeInputField.code else {
            // TODO: Show error message
            return
        }
        
        dependency.verificationService.requestVerification(
            email: dependency.email,
            verificationCode: verificationCode
        ) { result in
            do {
                try result.get()
                // TODO: Go to password view
            } catch {
                // TODO: Show error message
            }
        }
    }
}

// MARK: - Constant

private extension RequestVerificationViewController {
    
    enum Metric {
        static let inset: CGFloat = 16
    }
    
    enum Text {
        static let verificationButtonTitle = "이메일 재인증받기"
    }
}
