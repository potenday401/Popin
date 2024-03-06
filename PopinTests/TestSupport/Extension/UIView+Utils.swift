//
//  UIView+Utils.swift
//  PopinTests
//
//  Created by chamsol kim on 3/3/24.
//

import UIKit

extension UIView {
    
    func first<ViewType: UIView>(of type: ViewType.Type, with identifier: String) -> ViewType? {
        if self is ViewType {
            return self as? ViewType
        }
        
        for subview in subviews {
            guard let view = subview.first(of: type, with: identifier) else {
                continue
            }
            
            guard view.accessibilityIdentifier == identifier else {
                continue
            }
            
            return view
        }
        
        return nil
    }
}
