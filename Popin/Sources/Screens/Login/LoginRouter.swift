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
    
    struct Dependency {
        let network: Network
        let validator: EmailPasswordValidatorType
    }
    
    init(dependency: Dependency) {
        self.dependency = dependency
    }
    
    func routeToHome() {
        DispatchQueue.main.async {
            let homeViewController = HomeViewController()
            let cameraService = CameraService(network: self.dependency.network)
            let router = HomeRouterImp(cameraService: cameraService)
            homeViewController.router = router
            router.viewController = homeViewController
            
            if let window = self.window {
                window.rootViewController = UINavigationController(rootViewController: homeViewController)
                window.makeKeyAndVisible()
            }
        }
    }
    
    
    func routeToSignUp() {
        DispatchQueue.main.async {
            let signUpRouter = SignUpRouterImp(
                dependency: .init(
                    verificationService: VerificationServiceImp(network: self.dependency.network),
                    passwordService: PasswordServiceImp(network: self.dependency.network, validator: self.dependency.validator)
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
}
