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
    
    // MARK: - Interface
    
    weak var window: UIWindow?
    weak var viewController: UIViewController?
    
    func routeToHome() {
        DispatchQueue.main.async {
            self.window?.rootViewController = HomeViewController()
        }
    }
    
    func routeToSignUp() {
        DispatchQueue.main.async {
            let signUpRouter = SignUpRouterImp(
                dependency: .init(
                    verificationService: VerificationServiceImp(network: self.dependency.network),
                    passwordService: PasswordServiceImp(network: self.dependency.network)
                )
            )
            let signUpViewController = SignUpViewController()
            signUpViewController.router = signUpRouter
            signUpRouter.signUpViewController = signUpViewController
            
            self.viewController?.present(signUpViewController, animated: true)
        }
    }
    
    // MARK: - Property
    
    private let dependency: Dependency
    
    // MARK: - Initializer
    
    struct Dependency {
        let network: Network
    }
    
    init(dependency: Dependency) {
        self.dependency = dependency
    }
}
