//
//  UIImage+Utils.swift
//  Popin
//
//  Created by chamsol kim on 2/23/24.
//

import UIKit

extension UIImage {
    
    static func image(with color: UIColor) -> UIImage? {
        let size = CGSize(width: 1.0, height: 1.0)
        
        UIGraphicsBeginImageContext(size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        context.setFillColor(color.cgColor)
        context.fill(.init(origin: .zero, size: size))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
         
        return image
    }
}
