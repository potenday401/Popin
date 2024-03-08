//
//  SignUpRouter.swift
//  Popin
//
//  Created by chamsol kim on 3/8/24.
//

import UIKit

protocol SignUpRouter {
    func routeToRequestVerificationCode() -> UINavigationController?
}

final class SignUpRouterImp: SignUpRouter {
    
    // MARK: - Interface
    
    weak var signUpViewController: UIViewController?
    
    func routeToRequestVerificationCode() -> UINavigationController? {
        let viewController = RequestVerificationCodeViewController(
            title: "이메일을 적어주세요",
            dependency: .init(verificationService: dependency.verificationService)
        )
        viewController.showsProgress = true
        
        let navigationController = BaseNavigationViewController(rootViewController: viewController)
        
        signUpViewController?.addChild(navigationController)
        
        let subview = navigationController.view!
        signUpViewController?.view.addSubview(subview)
        subview.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        signUpViewController?.didMove(toParent: signUpViewController)
        
        return navigationController
    }
    
    // MARK: - Property
    
    private let dependency: Dependency
    
    // MARK: - Initializer
    
    struct Dependency {
        let verificationService: VerificationService
    }
    
    init(dependency: Dependency) {
        self.dependency = dependency
    }
    
}
