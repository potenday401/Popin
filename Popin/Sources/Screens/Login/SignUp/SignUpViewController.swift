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
    
    private let requestVerificationEmailViewController: UIViewController = {
        let viewController = RequestVerificationEmailViewController(title: "이메일을 적어주세요")
        viewController.showsProgress = true
        return viewController
    }()
    
    // MARK: - Setup
    
    override func setUpUI() {
        addChildNavigationController()
    }
    
    private func addChildNavigationController() {
        let navigationController = BaseNavigationViewController(rootViewController: requestVerificationEmailViewController)
        
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
