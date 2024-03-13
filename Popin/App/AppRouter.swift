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
    func createHomeRouter() -> HomeRouter
}

final class AppRouterImp: AppRouter {
    
    // MARK: - Interface
    
    weak var window: UIWindow?
    
    func launch() {
        window?.rootViewController = isLoggedIn ? homeViewController : loginViewController
    }
    
    func createHomeRouter() -> HomeRouter {
        let homeRouter = HomeRouterImp()
        return homeRouter
    }
    
    private var loginViewController: UIViewController {
        let loginService = LoginServiceImp(network: dependency.network)
        let loginDependency = LoginViewController.Dependency(
            loginService: loginService,
            tokenRepository: dependency.tokenRepository
        )
        
        let loginRouter = LoginRouterImp(dependency: .init(network: dependency.network))
        loginRouter.window = window
        
        let loginViewController = LoginViewController(dependency: loginDependency)
        loginViewController.router = loginRouter
        loginRouter.viewController = loginViewController
        
        return loginViewController
    }
    
    private var homeViewController: UIViewController {
        let homeVC = HomeViewController()
        let navigationController = UINavigationController(rootViewController: homeVC)
        return navigationController
    }
    
    // MARK: - Property
    
    private let dependency: Dependency
    private var isLoggedIn = false
    
    // MARK: - Initializer
    
    struct Dependency {
        let network: Network
        let tokenRepository: TokenRepository
    }
    
    init(dependency: Dependency) {
        self.dependency = dependency
    }
}
