//
//  VerificationCodeInputField.swift
//  Popin
//
//  Created by chamsol kim on 2/26/24.
//

import UIKit
import SnapKit

final class VerificationCodeInputField: UIView {
    
    // MARK: - UI
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        return stackView
    }()
    
    private let digits: [VerificationCodeDigit]
    
    // MARK: - Properties
    
    private let numberOfDigits: Int

    // MARK: - Initialization
    
    init(numberOfDigits: Int) {
        self.numberOfDigits = numberOfDigits
        digits = (0..<numberOfDigits).map { index in
            let digit = VerificationCodeDigit()
            digit.number = String(index)
            return digit
        }
        super.init(frame: .zero)
        setUpUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpUI() {
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        digits.forEach(stackView.addArrangedSubview(_:))
    }
}
