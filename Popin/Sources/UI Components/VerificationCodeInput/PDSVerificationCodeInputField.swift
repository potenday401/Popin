//
//  PDSVerificationCodeInputField.swift
//  Popin
//
//  Created by chamsol kim on 2/26/24.
//

import UIKit
import SnapKit

final class PDSVerificationCodeInputField: UIView {
    
    // MARK: - Interface
    
    var isFailure = false {
        didSet {
            digits.forEach {
                $0.isFailure = isFailure
            }
        }
    }
    
    // MARK: - UI
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .numberPad
        textField.textContentType = .oneTimeCode
        textField.delegate = self
        return textField
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        return stackView
    }()
    
    private let digits: [PDSVerificationCodeDigit]
    
    // MARK: - Properties
    
    private let numberOfDigits: Int

    // MARK: - Initialization
    
    init(numberOfDigits: Int) {
        self.numberOfDigits = numberOfDigits
        digits = (0..<numberOfDigits).map { index in
            return PDSVerificationCodeDigit()
        }
        super.init(frame: .zero)
        setUpUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpUI() {
        addTapGesture()
        
        addSubview(textField)
        
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        digits.forEach(stackView.addArrangedSubview(_:))
    }
    
    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(tapGestureHandler(_:))
        )
        addGestureRecognizer(tapGesture)
    }
}

// MARK: - Actions

private extension PDSVerificationCodeInputField {
    
    @objc
    func tapGestureHandler(_ recognizer: UITapGestureRecognizer) {
        textField.becomeFirstResponder()
    }
}

// MARK: - UITextFieldDelegate

extension PDSVerificationCodeInputField: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {
            return true
        }
        
        guard !string.isEmpty else {
            return true
        }
        
        return text.count < numberOfDigits
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        defer {
            isFailure = false
        }
        
        guard let text = textField.text?.padding(
            toLength: numberOfDigits,
            withPad: "-",
            startingAt: 0
        ) else {
            return
        }
        
        zip(text.map(String.init), digits).forEach { number, digit in
            digit.setNumber(number)
        }
    }
}
