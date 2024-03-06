//
//  EmailVerificationViewController.swift
//  Popin
//
//  Created by chamsol kim on 3/5/24.
//

import UIKit
import SnapKit

final class EmailVerificationViewController: BaseViewController {
    
    // MARK: - Interface
    
    var showsProgress = false {
        didSet {
            progressView.isHidden = !showsProgress
        }
    }
    
    // MARK: - UI
    
    private lazy var _navigationBar: PDSNavigationBar = {
        let navigationBar = PDSNavigationBar()
        navigationBar.titleView = UIImageView(image: UIImage(resource: .logo))
        navigationBar.leftItem = .init(
            image: UIImage(resource: .chevronLeft),
            target: self,
            action: #selector(
                backDidTap
            )
        )
        return navigationBar
    }()
    
    private let progressView: SignUpProgressView = {
        let progressView = SignUpProgressView(step: 4)
        progressView.isHidden = true
        return progressView
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .equalSpacing
        stackView.spacing = 25
        return stackView
    }()
    
    private let titleLabel: UILabel
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

    
    // MARK: - Initializer
    
    init(title: String) {
        let label = UILabel()
        label.text = title
        label.textColor = .white
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        titleLabel = label
        
        super.init()
    }
    
    // MARK: - Setup
    
    override func setUpUI() {
        shouldEndEditingIfTouchesEnded = true
        
        view.addSubview(_navigationBar)
        _navigationBar.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        
        view.addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.top.equalTo(_navigationBar.snp.bottom).offset(30)
            make.leading.equalTo(view.safeAreaLayoutGuide).inset(34)
        }
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalTo(progressView.snp.bottom).offset(35)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(Metric.inset)
        }
        
        view.addSubview(verificationButton)
        verificationButton.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(Metric.inset)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-Metric.inset)
        }
        
        [titleLabel, emailInputField].forEach(stackView.addArrangedSubview(_:))
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
