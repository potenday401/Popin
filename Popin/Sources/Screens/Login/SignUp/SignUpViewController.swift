//
//  SignUpViewController.swift
//  Popin
//
//  Created by chamsol kim on 3/5/24.
//

import UIKit
import SnapKit

final class SignUpViewController: BaseViewController {
    
    // MARK: - Interface
    
    var router: SignUpRouter?
    
    // MARK: - UI
    
    private var _navigationController: UINavigationController?
    override var navigationController: UINavigationController? {
        _navigationController
    }
    
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
        let childNavigationController = router?.routeToRequestVerificationCode()
        _navigationController = childNavigationController
    }
}
