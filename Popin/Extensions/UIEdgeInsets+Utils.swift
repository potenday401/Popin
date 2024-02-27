//
//  UIEdgeInsets+Utils.swift
//  Popin
//
//  Created by chamsol kim on 2/27/24.
//

import UIKit

extension UIEdgeInsets {
    
    var vertical: CGFloat {
        top + bottom
    }
    
    var horizontal: CGFloat {
        `left` + `right`
    }
}
