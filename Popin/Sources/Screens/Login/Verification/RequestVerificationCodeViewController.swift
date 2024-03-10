//
//  RequestVerificationCodeViewController.swift
//  Popin
//
//  Created by chamsol kim on 3/5/24.
//

import UIKit
import SnapKit

protocol RequestVerificationCodeViewControllerDelegate: AnyObject {
    func requestVerificationCodeViewControllerBackDidTap(_ viewController: RequestVerificationCodeViewController)
    func requestVerificationCodeViewController(_ viewController: RequestVerificationCodeViewController, didSuccessRequestForEmail email: String)
}

final class RequestVerificationCodeViewController: LoginDetailBaseViewController {
    
    // MARK: - Interface
    
    weak var delegate: RequestVerificationCodeViewControllerDelegate?
    
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

private extension RequestVerificationCodeViewController {
    
    @objc
    func backDidTap() {
        delegate?.requestVerificationCodeViewControllerBackDidTap(self)
    }
    
    @objc
    func verifyDidTap() {
        guard let email = emailInputField.text else {
            // TODO: Show error message
            return
        }
        
        dependency.verificationService.requestVerificationCode(email: email) { [weak self] result in
            guard let self else {
                return
            }
            
            do {
                try result.get()
                self.delegate?.requestVerificationCodeViewController(self, didSuccessRequestForEmail: email)
            } catch {
                // TODO: Show error message
            }
        }
    }
}

// MARK: - Constant

private extension RequestVerificationCodeViewController {
    
    enum Metric {
        static let inset: CGFloat = 16
    }
    
    enum Text {
        static let emailPlaceholder = "사용자 이메일"
        static let verificationButtonTitle = "이메일 인증받기"
    }
}