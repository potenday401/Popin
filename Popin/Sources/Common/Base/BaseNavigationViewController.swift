//
//  BaseNavigationViewController.swift
//  Popin
//
//  Created by chamsol kim on 3/5/24.
//

import UIKit

class BaseNavigationViewController: UINavigationController {
    
    // MARK: - Initialization
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        modalPresentationStyle = .fullScreen
    }
    
    @available(*, unavailable)
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray600
        navigationBar.isHidden = true
        setUpUI()
    }
    
    // MARK: - Setup
    
    func setUpUI() {
        
    }
}
