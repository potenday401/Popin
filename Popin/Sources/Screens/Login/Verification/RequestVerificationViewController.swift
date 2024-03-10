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
    
    private let verificationCodeInputField = PDSVerificationCodeInputField(numberOfDigits: 5)
    private lazy var verificationButton: PDSButton = {
        let button = PDSButton(style: .primary)
        button.setTitle(Text.verificationButtonTitle)
        button.addTarget(self, action: #selector(verifyDidTap), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Property
    
    private let dependency: Dependency
    
    // MARK: - Initializer
    
    struct Dependency {
        let verificationService: VerificationService
    }
    
    init(title: String, dependency: Dependency) {
        self.dependency = dependency
        super.init(title: title)
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
            make.top.bottom.equalToSuperview()
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
        
        // TODO: Request Verification
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
