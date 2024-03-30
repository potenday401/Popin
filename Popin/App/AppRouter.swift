//
//  AppRouter.swift
//  Popin
//
//  Created by chamsol kim on 3/8/24.
//

import UIKit

protocol AppRouter {
    var window: UIWindow? { get set }
    func launch()
}

final class AppRouterImp: AppRouter {
    // MARK: - Interface
    weak var window: UIWindow?
    
    func launch() {
        window?.rootViewController = isLoggedIn ? homeViewController : loginViewController
    }
    
    private var loginViewController: UIViewController {
        let loginService = LoginServiceImp(
            network: dependency.network,
            validator: dependency.validator
        )
        let loginDependency = LoginViewController.Dependency(
            loginService: loginService,
            tokenRepository: dependency.tokenRepository
        )
        let loginRouter = LoginRouterImp(
            dependency: .init(
                network: dependency.network,
                validator: dependency.validator
            )
        )
        loginRouter.window = window
        
        let loginViewController = LoginViewController(dependency: loginDependency)
        loginViewController.router = loginRouter
        loginRouter.viewController = loginViewController
        
        return loginViewController
    }
    
    private var homeViewController: UIViewController {
        let homeViewController = HomeViewController()
        let cameraService = CameraService(network: dependency.network)
        let router = HomeRouterImp(cameraService: cameraService)
        homeViewController.router = router
        router.viewController = homeViewController
        return UINavigationController(rootViewController: homeViewController)
    }
    
    // MARK: - Property
    
    private let dependency: Dependency
    private var isLoggedIn = false
    
    // MARK: - Initializer
    
    struct Dependency {
        let network: Network
        let tokenRepository: TokenRepository
        let validator: EmailPasswordValidatorType
    }
    
    init(dependency: Dependency) {
        self.dependency = dependency
    }
}
