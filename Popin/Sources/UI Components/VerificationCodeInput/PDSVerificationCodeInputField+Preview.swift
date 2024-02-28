//
//  PDSVerificationCodeInputField+Preview.swift
//  Popin
//
//  Created by chamsol kim on 2/26/24.
//

import UIKit
import SnapKit

fileprivate final class VerificationCodeInputFieldPreviewViewController: UIViewController {
    
    private lazy var failureButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Set Failure", for: .normal)
        button.setTitle("Reset", for: .selected)
        button.addTarget(self, action: #selector(buttonDidTap(_:)), for: .touchUpInside)
        return button
    }()
    
    private let verificationCodeInputField = PDSVerificationCodeInputField(numberOfDigits: 5)
    
    private var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .gray600
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        [failureButton, verificationCodeInputField].forEach(stackView.addArrangedSubview(_:))
        
        verificationCodeInputField.setNumber("12345")
    }
    
    @objc
    private func buttonDidTap(_ button: UIButton) {
        button.isSelected.toggle()
        verificationCodeInputField.isFailure.toggle()
    }
}


#Preview {
    VerificationCodeInputFieldPreviewViewController()
}

fileprivate extension PDSVerificationCodeInputField {
    
    func setNumber(_ number: String) {
        let digits = subviews
            .compactMap { $0 as? UIStackView }
            .compactMap { $0.arrangedSubviews }
            .flatMap { $0 }
            .compactMap { $0 as? PDSVerificationCodeDigit }
        
        zip(number.map(String.init), digits).forEach { number, digit in
            digit.setNumber(number)
        }
    }
}
