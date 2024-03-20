//
//  PDSInputField.swift
//  Popin
//
//  Created by chamsol kim on 2/27/24.
//

import UIKit
import SnapKit

final class PDSInputField: UIView {
    
    // MARK: - Interface
    
    var placeholder: String? {
        get { placeholderLabel.text }
        set { placeholderLabel.text = newValue }
    }
    
    var text: String? {
        get { textField.text }
        set {
            textField.text = newValue
            updatePlaceholderLabel(hasText: newValue != nil)
            updateSecureTextVisibilityButtonShowing()
        }
    }
    
    var isSecureTextEntry = false {
        didSet {
            textField.isSecureTextEntry = isSecureTextEntry
            updateSecureTextVisibilityButtonShowing()
        }
    }
    
    var isFailure: Bool {
        get { state == .error }
        set {
            guard state != .fixed else {
                return
            }
            state = newValue ? .error : .normal
        }
    }
    
    var isFixed: Bool {
        get { state == .fixed }
        set { state = .fixed }
    }
    
    // MARK: - Property
    
    private var state: State = .normal {
        didSet {
            updateColors(for: state)
            isUserInteractionEnabled = state != .fixed
        }
    }
    
    private var isSecureTextVisible = false {
        didSet {
            secureTextVisibilityButton.alpha = Constant.secureTextVisibilityAlpha(isVisible: isSecureTextVisible)
            
            guard isSecureTextEntry else {
                textField.isSecureTextEntry = false
                return
            }
            
            textField.isSecureTextEntry = !isSecureTextVisible
        }
    }
    
    // MARK: - UI
    
    private let placeholderLabel = UILabel()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.font = Font.mainFont
        textField.delegate = self
        return textField
    }()
    
    private lazy var secureTextVisibilityButton: UIButton = {
        let button = UIButton(type: .system)
        button.setBackgroundImage(UIImage(resource: .eye), for: .normal)
        button.addTarget(self, action: #selector(showPasswordDidTap), for: .touchUpInside)
        button.alpha = Constant.secureTextVisibilityAlpha(isVisible: false)
        return button
    }()
    
    private let textContentView = UIView()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.spacing = Metric.spacing
        return stackView
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpUI() {
        addTapGesture()
        
        layer.cornerRadius = 12
        updateColors(for: .normal)
        
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(Metric.normalLeftInset)
            make.trailing.equalToSuperview().inset(Metric.inset)
            make.centerY.equalToSuperview()
        }
        
        stackView.addArrangedSubview(textContentView)
        textContentView.snp.makeConstraints { make in
            make.height.equalTo(Metric.height - Metric.inset.vertical)
        }
        
        [textField, placeholderLabel].forEach(textContentView.addSubview(_:))
        textField.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        updatePlaceholderLabel(hasText: false)
        
        secureTextVisibilityButton.snp.makeConstraints { make in
            make.size.equalTo(Metric.imageSize)
        }
    }
    
    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(tapGestureHandler(_:))
        )
        addGestureRecognizer(tapGesture)
    }
    
    private func updatePlaceholderLabel(hasText: Bool) {
        placeholderLabel.font = hasText ? Font.subFont : Font.mainFont
        placeholderLabel.snp.remakeConstraints { make in
            make.leading.trailing.equalToSuperview()
            
            if hasText {
                make.top.equalToSuperview()
            } else {
                make.centerY.equalToSuperview()
            }
        }
        
        updateStackViewLayout(leftInset: hasText ? Metric.inset.left : Metric.normalLeftInset)
    }
    
    private func updateStackViewLayout(leftInset: CGFloat) {
        stackView.snp.updateConstraints { make in
            make.leading.equalToSuperview().inset(leftInset)
        }
    }
    
    private func updateSecureTextVisibilityButtonShowing() {
        if isSecureTextEntry, let text, !text.isEmpty {
            stackView.addArrangedSubview(secureTextVisibilityButton)
        } else {
            secureTextVisibilityButton.removeFromSuperview()
        }
    }
    
    private func updateColors(for state: State) {
        backgroundColor = state.backgroundColor
        layer.borderWidth = state == .normal ? 0 : 1
        layer.borderColor = state.borderColor
        textField.textColor = state.textColor
        placeholderLabel.textColor = state.placeholderColor
    }
    
    // MARK: - Intrinsic Content Size
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: CGFloat.greatestFiniteMagnitude, height: 64)
    }
}

// MARK: - Action

private extension PDSInputField {
    
    @objc
    func tapGestureHandler(_ recognizer: UITapGestureRecognizer) {
        guard !textField.isFirstResponder else {
            return
        }
        
        textField.becomeFirstResponder()
    }
    
    @objc
    func showPasswordDidTap() {
        isSecureTextVisible.toggle()
    }
}

// MARK: - UITextFieldDelegate

extension PDSInputField: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        updatePlaceholderLabel(hasText: true)
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        updateSecureTextVisibilityButtonShowing()
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        guard textField.text?.isEmpty == true else {
            return true
        }
        
        updatePlaceholderLabel(hasText: false)
        updateSecureTextVisibilityButtonShowing()
        return true
    }
}

// MARK: - State

extension PDSInputField {
    
    enum State {
        case normal
        case error
        case fixed
        
        var textColor: UIColor {
            switch self {
            case .normal:   .white
            case .error:    .pink200
            case .fixed:    .gray200
            }
        }
        
        var placeholderColor: UIColor {
            switch self {
            case .normal:   .white
            case .error:    .white
            case .fixed:    .gray100
            }
        }
        
        var backgroundColor: UIColor {
            switch self {
            case .normal:   .gray300
            case .error:    .gray300
            case .fixed:    .gray500
            }
        }
        
        var borderColor: CGColor {
            switch self {
            case .normal:   UIColor.clear.cgColor
            case .error:    UIColor.pink200.cgColor
            case .fixed:    UIColor.gray400.cgColor
            }
        }
    }
}

// MARK: - Constant

private extension PDSInputField {
    
    enum Metric {
        static let height: CGFloat = 64
        static let inset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        static let normalLeftInset: CGFloat = 26
        static let spacing: CGFloat = 4
        static let imageSize: CGFloat = 24
    }
    
    enum Font {
        static let mainFont = UIFont.systemFont(ofSize: 16, weight: .medium)
        static let subFont = UIFont.systemFont(ofSize: 14, weight: .regular)
    }
    
    enum Constant {
        static func secureTextVisibilityAlpha(isVisible: Bool) -> CGFloat {
            isVisible ? 1 : 0.2
        }
    }
}
