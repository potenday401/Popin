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
        notificationCenter.addObserver(for: .willShow) { [weak self] notification in
            guard let keyboardNotification = KeyboardNotificationUserInfo(notification) else {
                return
            }
            self?.keyboardWillShowNotification(keyboardNotification)
        }
        notificationCenter.addObserver(for: .willHide) { [weak self] notification in
            guard let keyboardNotification = KeyboardNotificationUserInfo(notification) else {
                return
            }
            self?.keyboardWillHideNotification(keyboardNotification)
        }
        notificationCenter.addObserver(for: .didShow) { [weak self] notification in
            guard let keyboardNotification = KeyboardNotificationUserInfo(notification) else {
                return
            }
            self?.keyboardDidShowNotification(keyboardNotification)
        }
        notificationCenter.addObserver(for: .didHide) { [weak self] notification in
            guard let keyboardNotification = KeyboardNotificationUserInfo(notification) else {
                return
            }
            self?.keyboardDidHideNotification(keyboardNotification)
        }
        notificationCenter.addObserver(for: .willChangeFrame) { [weak self] notification in
            guard let keyboardNotification = KeyboardNotificationUserInfo(notification) else {
                return
            }
            self?.keyboardWillChangeFrameNotification(keyboardNotification)
        }
        notificationCenter.addObserver(for: .didChangeFrame) { [weak self] notification in
            guard let keyboardNotification = KeyboardNotificationUserInfo(notification) else {
                return
            }
            self?.keyboardDidChangeFrameNotification(keyboardNotification)
        }
    }
}
