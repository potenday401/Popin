//
//  UIStackView+Utils.swift
//  Popin
//
//  Created by chamsol kim on 2/26/24.
//

import UIKit

extension UIStackView {
    
    func removeAllArrangedSubviews() {
        arrangedSubviews.forEach(removeArrangedSubview(_:))
    }
}
