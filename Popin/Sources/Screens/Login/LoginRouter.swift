//
//  LoginRouter.swift
//  Popin
//
//  Created by chamsol kim on 3/8/24.
//

import UIKit

protocol LoginRouter {
    func routeToHome()
}

final class LoginRouterImp: LoginRouter {
    
    weak var window: UIWindow?
    
    func routeToHome() {
        DispatchQueue.main.async {
            self.window?.rootViewController = HomeViewController()
        }
    }
}
