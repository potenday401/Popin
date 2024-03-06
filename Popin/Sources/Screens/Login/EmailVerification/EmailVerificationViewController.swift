//
//  EmailVerificationViewController.swift
//  Popin
//
//  Created by chamsol kim on 3/5/24.
//

import UIKit
import SnapKit

final class EmailVerificationViewController: LoginDetailBaseViewController {
    
    // MARK: - UI
    
    private let emailInputField: PDSInputField = {
        let inputField = PDSInputField()
        inputField.placeholder = Text.emailPlaceholder
        return inputField
    }()
    private lazy var verificationButton: PDSButton = {
        let button = PDSButton(style: .primary)
        button.setTitle(Text.verificationButtonTitle)
        button.addTarget(self, action: #selector(verifyDidTap), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Setup
    
    override func setUpUI() {
        super.setUpUI()
        
        contentView.addSubview(emailInputField)
        emailInputField.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(verificationButton)
        verificationButton.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(Metric.inset)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-Metric.inset)
        }
    }
    
    // MARK: - Keyboard
    
    override func keyboardWillShowNotification(_ userInfo: KeyboardNotificationUserInfo) {
        print(#function, userInfo)
        updateVerificationButtonLayout(
            withDuration: userInfo.animationDuration,
            options: userInfo.animationCurveOptions,
            with: -userInfo.endFrame.height
        )
    }
    
    override func keyboardWillHideNotification(_ userInfo: KeyboardNotificationUserInfo) {
        print(#function, userInfo)
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

private extension EmailVerificationViewController {
    
    @objc
    func backDidTap() {
        dismiss(animated: true)
    }
    
    @objc
    func verifyDidTap() {
        // TODO: Request verification
    }
}

// MARK: - Constant

private extension EmailVerificationViewController {
    
    enum Metric {
        static let inset: CGFloat = 16
    }
    
    enum Text {
        static let emailPlaceholder = "사용자 이메일"
        static let verificationButtonTitle = "이메일 인증받기"
    }
}
