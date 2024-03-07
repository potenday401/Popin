//
//  NotificationCenter+Utils.swift
//  Popin
//
//  Created by chamsol kim on 3/6/24.
//

import Foundation

extension NotificationCenter {
    
    func addObserver(for keyboardNotification: KeyboardNotification, using block: @escaping (KeyboardNotificationUserInfo) -> Void) {
        addObserver(forName: keyboardNotification.notificationName, object: nil, queue: .main) { notification in
            guard let userInfo = KeyboardNotificationUserInfo(notification) else {
                return
            }
            block(userInfo)
        }
    }
}
