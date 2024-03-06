//
//  File.swift
//  Popin
//
//  Created by 나리강 on 2/3/24.
//

import UIKit

class BaseViewController: UIViewController, KeyboardSupport {
    
    // MARK: - Interface
    
    var shouldEndEditingIfTouchesEnded = false
    
    // MARK: - Initialization
    
    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray600
        observeKeyboardNotification()
        setUpUI()
    }
    
    // MARK: - Setup
    
    func setUpUI() {
        
    }
    
    // MARK: - Touch
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard shouldEndEditingIfTouchesEnded else {
            return
        }
        view.endEditing(true)
    }
    
    // MARK: - Keyboard
    
    func keyboardWillShowNotification(_ userInfo: KeyboardNotificationUserInfo) {
        
    }
    
    func keyboardWillHideNotification(_ userInfo: KeyboardNotificationUserInfo) {
        
    }
    
    func keyboardDidShowNotification(_ userInfo: KeyboardNotificationUserInfo) {
        
    }
    
    func keyboardDidHideNotification(_ userInfo: KeyboardNotificationUserInfo) {
        
    }
    
    func keyboardWillChangeFrameNotification(_ userInfo: KeyboardNotificationUserInfo) {
        
    }
    
    func keyboardDidChangeFrameNotification(_ userInfo: KeyboardNotificationUserInfo) {
        
    }
}
