//
//  InputField.swift
//  Popin
//
//  Created by Jihaha kim on 2024/02/21.
//

import UIKit

protocol TextInputDesignSystem {
    var textColor: UIColor { get }
    var backgroundColor: UIColor { get }
    var borderColor: UIColor { get }
    var borderWidth: CGFloat { get }
    var cornerRadius: CGFloat { get }
}

struct DefaultTextInputDesignSystem: TextInputDesignSystem {
    let textColor: UIColor = .black
    let backgroundColor: UIColor = UIColor.grey300
    let borderColor: UIColor = .grey300
    let borderWidth: CGFloat = 1.0
    let cornerRadius: CGFloat = 12.0
}

class CustomTextField: UITextField {
    var designSystem: TextInputDesignSystem? {
        didSet {
            applyDesignSystem()
        }
    }
    
    private func applyDesignSystem() {
        guard let designSystem = designSystem else { return }
        
        textColor = designSystem.textColor
        backgroundColor = designSystem.backgroundColor
        layer.borderColor = designSystem.borderColor.cgColor
        layer.borderWidth = designSystem.borderWidth
        layer.cornerRadius = designSystem.cornerRadius
    }
}

/// 사용 예시
///let textField = CustomTextField(frame: CGRect(x: 50, y: 100, width: 200, height: 30))
///let designSystem = DefaultTextInputDesignSystem()
/// textField.designSystem = designSystem
