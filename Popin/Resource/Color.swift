//
//  color.swift
//  Popin
//
//  Created by 나리강 on 2/4/24.
//

import UIKit

struct Color {
    
    static let shared = Color()
    private init () { }
    
    let buttonColor = UIColor(red: 94/255, green: 92/255, blue: 230/255, alpha: 1)
    let textFieldColor = UIColor(red: 72/255, green: 72/255, blue: 74/255, alpha: 1)

    let Yellow = UIColor(red: 244/255, green: 164/255, blue: 66/255, alpha: 1)
    let darkGray = UIColor(red: 148/255, green: 148/255, blue: 148/255, alpha: 1)
    let backgroundGray = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
    let lineGray = UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 1)
    let black = UIColor.black
    let white = UIColor.white
    
}

