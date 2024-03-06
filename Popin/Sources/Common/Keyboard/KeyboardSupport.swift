//
//  KeyboardSupport.swift
//  Popin
//
//  Created by chamsol kim on 3/6/24.
//

import UIKit

protocol KeyboardSupport: UIViewController {}

extension KeyboardSupport where Self : BaseViewController {
    
    func observeKeyboardNotification() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(for: .willShow, using: keyboardWillShowNotification(_:))
        notificationCenter.addObserver(for: .willHide, using: keyboardWillHideNotification(_:))
        notificationCenter.addObserver(for: .didShow, using: keyboardDidShowNotification(_:))
        notificationCenter.addObserver(for: .didHide, using: keyboardDidHideNotification(_:))
        notificationCenter.addObserver(for: .willChangeFrame, using: keyboardWillChangeFrameNotification(_:))
        notificationCenter.addObserver(for: .didChangeFrame, using: keyboardDidChangeFrameNotification(_:))
    }
}
