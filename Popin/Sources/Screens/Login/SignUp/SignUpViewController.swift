//
//  SignUpViewController.swift
//  Popin
//
//  Created by chamsol kim on 3/5/24.
//

import UIKit
import SnapKit

final class SignUpViewController: BaseViewController {
    
    // MARK: - UI
    
    private var _navigationController: UINavigationController?
    override var navigationController: UINavigationController? {
        _navigationController
    }
    
    private lazy var requestVerificationCodeViewController: UIViewController = {
        let service = VerificationServiceImp(network: dependency.network)
        let viewController = RequestVerificationCodeViewController(
            title: "이메일을 적어주세요",
            dependency: .init(loginService: service)
        )
        viewController.showsProgress = true
        return viewController
    }()
    
    // MARK: - Property
    
    private let dependency: Dependency
    
    // MARK: - Initializer
    
    struct Dependency {
        let network: Network
    }
    
    init(dependency: Dependency) {
        self.dependency = dependency
        super.init()
    }
    
    // MARK: - Setup
    
    override func setUpUI() {
        addChildNavigationController()
    }
    
    private func addChildNavigationController() {
        let navigationController = BaseNavigationViewController(rootViewController: requestVerificationCodeViewController)
        
        addChild(navigationController)
        
        let subview = navigationController.view!
        view.addSubview(subview)
        subview.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        didMove(toParent: self)
        
        _navigationController = navigationController
    }
}
