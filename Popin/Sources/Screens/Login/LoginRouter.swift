//
//  LoginRouter.swift
//  Popin
//
//  Created by chamsol kim on 3/8/24.
//

import UIKit

protocol LoginRouter {
    func routeToHome(accessToken: String, refreshToken: String)
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
    
    func routeToHome(accessToken: String, refreshToken: String) {
        DispatchQueue.main.async {
            let homeViewController = HomeViewController(accessToken: accessToken, refreshToken: refreshToken)
            let cameraService = CameraService(network: self.dependency.network)
            let router = HomeRouterImp(cameraService: cameraService)
            homeViewController.router = router
            router.viewController = homeViewController
            TokenManager.shared.saveTokens(accessToken: accessToken, refreshToken: refreshToken)

            if let keyWindow = UIApplication.shared.keyWindow {
                keyWindow.rootViewController = UINavigationController(rootViewController: homeViewController)
                keyWindow.makeKeyAndVisible()
            } else {
                if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
                    rootViewController.present(homeViewController, animated: true, completion: nil)
                } else {
                    print("Could not present homeViewController: rootViewController is nil")
                }
            }
        }
    }
    
    func routeToSignUp() {
        DispatchQueue.main.async {
            let signUpRouter = SignUpRouterImp(
                dependency: .init(
                    verificationService: VerificationServiceImp(network: self.dependency.network),
                    passwordService: PasswordServiceImp(network: self.dependency.network, validator: self.dependency.validator), network: self.dependency.network
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
