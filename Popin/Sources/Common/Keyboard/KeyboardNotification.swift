//
//  KeyboardNotification.swift
//  Popin
//
//  Created by chamsol kim on 3/6/24.
//

import UIKit

enum KeyboardNotification {
    case willShow
    case willHide
    case didShow
    case didHide
    case willChangeFrame
    case didChangeFrame
    
    var notificationName: Notification.Name {
        switch self {
        case .willShow:         UIResponder.keyboardWillShowNotification
        case .willHide:         UIResponder.keyboardWillHideNotification
        case .didShow:          UIResponder.keyboardDidShowNotification
        case .didHide:          UIResponder.keyboardDidHideNotification
        case .willChangeFrame:  UIResponder.keyboardWillChangeFrameNotification
        case .didChangeFrame:   UIResponder.keyboardDidChangeFrameNotification
        }
    }
}
