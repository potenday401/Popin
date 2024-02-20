//
//  Button.swift
//  Popin
//
//  Created by Jihaha kim on 2024/02/21.
//

import UIKit

struct ButtonStyle {
    let backgroundColorClosure: () -> UIColor
    let titleColor: UIColor
    let cornerRadius: CGFloat
    let borderWidth: CGFloat
    let borderColor: UIColor
    let font: UIFont
}

extension ButtonStyle {
    static func custom(backgroundColorClosure: @escaping () -> UIColor, titleColor: UIColor, cornerRadius: CGFloat, borderWidth: CGFloat, borderColor: UIColor, font: UIFont) -> ButtonStyle {
        return ButtonStyle(
            backgroundColorClosure: backgroundColorClosure,
            titleColor: titleColor,
            cornerRadius: cornerRadius,
            borderWidth: borderWidth,
            borderColor: borderColor,
            font: font
        )
    }
    
    static let large = ButtonStyle(
        backgroundColorClosure: { return .blue },
        titleColor: .white,
        cornerRadius: 8,
        borderWidth: 0,
        borderColor: .clear,
        font: UIFont.systemFont(ofSize: 20, weight: .semibold)
    )
    
    static let small = ButtonStyle(
        backgroundColorClosure: { return .green },
        titleColor: .white,
        cornerRadius: 8,
        borderWidth: 0,
        borderColor: .clear,
        font: UIFont.systemFont(ofSize: 14, weight: .semibold)
    )
    
    static let xsmall = ButtonStyle(
        backgroundColorClosure: { return .red },
        titleColor: .white,
        cornerRadius: 24,
        borderWidth: 0,
        borderColor: .clear,
        font: UIFont.systemFont(ofSize: 12, weight: .semibold)
    )
}

extension UIButton {
    func setSize(width: CGFloat, height: CGFloat) {
        self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: width, height: height)
    }
    
    convenience init(style: ButtonStyle) {
        self.init()
        self.backgroundColor = style.backgroundColorClosure()
        self.setTitleColor(style.titleColor, for: .normal)
        self.layer.cornerRadius = style.cornerRadius
        self.layer.borderWidth = style.borderWidth
        self.layer.borderColor = style.borderColor.cgColor
        self.titleLabel?.font = style.font
    }
}
