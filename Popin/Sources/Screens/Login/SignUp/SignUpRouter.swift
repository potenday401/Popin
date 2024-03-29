//
//  SignUpRouter.swift
//  Popin
//
//  Created by chamsol kim on 3/8/24.
//

import UIKit

protocol SignUpRouter {
    func routeToRequestVerificationCode() -> UINavigationController?
    func dismissFromRequestVerificationCode()
    func routeToRequestVerification(email: String)
    func dismissFromRequestVerification()
    func routeToPassword(email: String)
    func dismissFromPassword()
    func routeToAgreement()
}

final class SignUpRouterImp: SignUpRouter {
    
    // MARK: - Interface
    
    weak var signUpViewController: SignUpViewController?
    
    func routeToRequestVerificationCode() -> UINavigationController? {
        let viewController = RequestVerificationCodeViewController(
            title: "이메일을 적어주세요",
            numberOfStep: numberOfStep,
            step: 1,
            dependency: .init(verificationService: dependency.verificationService)
        )
        viewController.showsProgress = true
        viewController.delegate = signUpViewController
        
        let navigationController = BaseNavigationViewController(rootViewController: viewController)
        
        signUpViewController?.addChild(navigationController)
        
        let subview = navigationController.view!
        signUpViewController?.view.addSubview(subview)
        subview.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        navigationController.didMove(toParent: signUpViewController)
        
        return navigationController
    }
    
    func dismissFromRequestVerificationCode() {
        signUpViewController?.navigationController?.view.removeFromSuperview()
        signUpViewController?.navigationController?.viewControllers = []
        signUpViewController?.dismiss(animated: true)
    }
    
    func routeToRequestVerification(email: String) {
        let viewController = RequestVerificationViewController(
            title: "인증번호를 확인하세요",
            numberOfStep: numberOfStep,
            step: 2,
            dependency: .init(email: email, verificationService: dependency.verificationService)
        )
        viewController.showsProgress = true
        viewController.delegate = signUpViewController
        
        signUpViewController?.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func dismissFromRequestVerification() {
        signUpViewController?.navigationController?.popViewController(animated: true)
    }
    
    func routeToPassword(email: String) {
        let viewController = PasswordViewController(
            title: "비밀번호를 적어주세요",
            numberOfStep: numberOfStep,
            step: 3,
            dependency: .init(email: email, passwordService: dependency.passwordService)
        )
        viewController.delegate = signUpViewController
        
        signUpViewController?.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func dismissFromPassword() {
        signUpViewController?.navigationController?.popViewController(animated: true)
    }
    
    func routeToAgreement() {
        let viewController = AgreementViewController(title: "약관동의", numberOfStep: numberOfStep, step: 4)
        signUpViewController?.navigationController?.pushViewController(viewController, animated: true)
    }
    
    // MARK: - Property
    
    private let dependency: Dependency
    
    private let numberOfStep = 4
    
    // MARK: - Initializer
    
    struct Dependency {
        let verificationService: VerificationService
        let passwordService: PasswordService
    }
    
    init(dependency: Dependency) {
        self.dependency = dependency
    }
    
}
