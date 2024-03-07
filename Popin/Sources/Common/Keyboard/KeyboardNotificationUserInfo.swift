//
//  KeyboardNotificationUserInfo.swift
//  Popin
//
//  Created by chamsol kim on 3/6/24.
//

import UIKit

struct KeyboardNotificationUserInfo {
    let beginFrame: CGRect
    let endFrame: CGRect
    let animationDuration: TimeInterval
    let animationCurveOptions: UIView.AnimationOptions
    
    init?(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let beginFrame = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect,
              let endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
              let animationCurve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        else {
            return nil
        }
        
        self.beginFrame = beginFrame
        self.endFrame = endFrame
        self.animationDuration = animationDuration
        animationCurveOptions = UIView.AnimationOptions(rawValue: animationCurve << 16)
    }
}
