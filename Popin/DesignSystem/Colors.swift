//
//  Colors.swift
//  Popin
//
//  Created by Jihaha kim on 2024/02/21.
//

import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int, a: Int = 0xFF) {
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: CGFloat(a) / 255.0
        )
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
    
    convenience init(argb: Int) {
        self.init(
            red: (argb >> 16) & 0xFF,
            green: (argb >> 8) & 0xFF,
            blue: argb & 0xFF,
            a: (argb >> 24) & 0xFF
        )
    }
    static var white: UIColor {
           return UIColor(rgb: 0xFFFFFF)
       }
    static var grey100: UIColor {
           return UIColor(rgb: 0x848794)
       }
    static var grey200: UIColor {
           return UIColor(rgb: 0x565D68)
       }
    static var grey300: UIColor {
           return UIColor(rgb: 0x3D444F)
       }
    static var grey400: UIColor {
           return UIColor(rgb: 0x212730)
       }
    static var grey500: UIColor {
           return UIColor(rgb: 0x11161F)
       }
    static var grey600: UIColor {
           return UIColor(rgb: 0x0A0E18)
       }
    static var grey700: UIColor {
           return UIColor(rgb: 0x0A0514)
       }
    static var indigo100: UIColor {
           return UIColor(rgb: 0x7D7AFF)
       }
    static var indigo200: UIColor {
           return UIColor(rgb: 0x5E5CE6)
       }
    static var indigo300: UIColor {
           return UIColor(rgb: 0x3634A3)
       }
    static var purple100: UIColor {
           return UIColor(rgb: 0xDA8FFF)
       }
    static var purple200: UIColor {
           return UIColor(rgb: 0xBF5AF2)
       }
    static var purple300: UIColor {
           return UIColor(rgb: 0x8944AB)
       }
    static var pink100: UIColor {
           return UIColor(rgb: 0xFF6482)
       }
    static var pink200: UIColor {
           return UIColor(rgb: 0xFF2D55)
       }
    static var pink300: UIColor {
           return UIColor(rgb: 0xD30F45)
       }
    static var yellow100: UIColor {
           return UIColor(rgb: 0xF8FC3C)
       }
}
