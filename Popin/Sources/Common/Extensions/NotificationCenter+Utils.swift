//
//  NotificationCenter+Utils.swift
//  Popin
//
//  Created by chamsol kim on 3/6/24.
//

import Foundation

extension NotificationCenter {
    
    func addObserver(for keyboardNotification: KeyboardNotification, using block: @escaping (Notification) -> Void) {
        addObserver(forName: keyboardNotification.notificationName, object: nil, queue: .main, using: block) 
    }
}
