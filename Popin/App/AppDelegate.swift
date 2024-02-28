//
//  AppDelegate.swift
//  fourpin
//
//  Created by Jihaha kim on 2024/01/30.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = LoginViewController()
        window.makeKeyAndVisible()
        
        self.window = window
        
        return true
    }
}

