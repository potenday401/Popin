//
//  LoginRouter.swift
//  Popin
//
//  Created by chamsol kim on 3/8/24.
//

import UIKit

protocol LoginRouter {
    func routeToHome()
    func routeToSignUp()
}

final class LoginRouterImp: LoginRouter {
    
    weak var window: UIWindow?
    weak var viewController: UIViewController?
    
    func routeToHome() {
        DispatchQueue.main.async {
            self.window?.rootViewController = HomeViewController()
        }
    }
    
    func routeToSignUp() {
        DispatchQueue.main.async {
            let signUpViewController = SignUpViewController()
            self.viewController?.present(signUpViewController, animated: true)
        }
    }
}
