//
//  Text.swift
//  Popin
//
//  Created by Jihaha kim on 2024/02/21.
//
import UIKit

struct TextStyle {
    let font: UIFont
    let size: CGFloat
    let weight: UIFont.Weight
    let color: UIColor
    let lineHeight: CGFloat
    let letterSpacing: CGFloat
}

extension TextStyle {
    static let LargeTitle = TextStyle(font: UIFont.systemFont(ofSize: 34, weight: .regular), size: 34, weight: .regular, color: .black, lineHeight: 41, letterSpacing: 0.37)
    static let title1 = TextStyle(font: UIFont.systemFont(ofSize: 28, weight: .regular), size: 28, weight: .regular, color: .black, lineHeight: 34, letterSpacing: 0.36)
    static let title2 = TextStyle(font: UIFont.systemFont(ofSize: 22, weight: .regular), size: 22, weight: .regular, color: .black, lineHeight: 28, letterSpacing: 0.35)
    static let title3 = TextStyle(font: UIFont.systemFont(ofSize: 20, weight: .regular), size: 20, weight: .regular, color: .black, lineHeight: 24, letterSpacing: 0.38)
    static let Headline = TextStyle(font: UIFont.systemFont(ofSize: 17, weight: .semibold), size: 17, weight: .semibold, color: .black, lineHeight: 22, letterSpacing: -0.41)
    //...
}

