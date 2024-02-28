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
        }
    }
    
    var isSecureTextEntry: Bool {
        get { textField.isSecureTextEntry }
        set {
            textField.isSecureTextEntry = newValue
            
            if newValue {
                stackView.addArrangedSubview(showPasswordButton)
            } else {
                showPasswordButton.removeFromSuperview()
            }
        }
    }
    
    // MARK: - Property
    
    private var state: State = .normal {
        didSet {
            updateColors(for: state)
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
    
    private lazy var showPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setBackgroundImage(UIImage(resource: .eye), for: .normal)
        button.addTarget(self, action: #selector(showPasswordDidTap), for: .touchUpInside)
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
            make.leading.trailing.equalToSuperview().inset(Metric.inset)
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
        
        showPasswordButton.snp.makeConstraints { make in
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
    }
    
    private func updateColors(for state: State) {
        backgroundColor = state.backgroundColor
        layer.borderWidth = state == .focused ? 1 : 0
        layer.borderColor = state.primaryColor.cgColor
        textField.textColor = state.primaryColor
        placeholderLabel.textColor = state.secondaryColor
    }
    
    // MARK: - Intrinsic Content Size
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: 0, height: 64)
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
        textField.isSecureTextEntry.toggle()
    }
}

// MARK: - UITextFieldDelegate

extension PDSInputField: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        state = .focused
        updatePlaceholderLabel(hasText: true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        state = .normal
        
        guard textField.text?.isEmpty == true else {
            return true
        }
        
        updatePlaceholderLabel(hasText: false)
        return true
    }
}

// MARK: - State

extension PDSInputField {
    
    enum State {
        case normal
        case focused
        
        var primaryColor: UIColor {
            switch self {
            case .normal:   .white
            case .focused:  .indigo100
            }
        }
        
        var secondaryColor: UIColor {
            switch self {
            case .normal:   .white
            case .focused:  .gray300
            }
        }
        
        var backgroundColor: UIColor {
            switch self {
            case .normal:   .gray300
            case .focused:  .gray500
            }
        }
    }
}

// MARK: - Constant

private extension PDSInputField {
    
    enum Metric {
        static let height: CGFloat = 64
        static let inset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        static let spacing: CGFloat = 4
        static let imageSize: CGFloat = 24
    }
    
    enum Font {
        static let mainFont = UIFont.systemFont(ofSize: 16, weight: .medium)
        static let subFont = UIFont.systemFont(ofSize: 14, weight: .regular)
    }
}
