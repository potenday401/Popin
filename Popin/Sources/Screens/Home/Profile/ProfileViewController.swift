//
//  ProfileViewController.swift
//  Popin
//
//  Created by Jihaha kim on 2024/03/13.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    var router: ProfileRouter?
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let profileRouter = ProfileRouterImp()
        profileRouter.viewController = self
        router = profileRouter
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupUI()
    }
    
    // MARK: - Private Methods
    
    // animation 효과때문에 단순 back으로 하는게 좋을지?
    @objc
    func backDidTap() {
        router?.routeToEditProfile()
    }
    
    private let navigationBar: PDSNavigationBar = {
        let navigationBar = PDSNavigationBar()
        navigationBar.title = "마이페이지"
        return navigationBar
    }()
    
    private func setupUI() {
        view.addSubview(navigationBar)
        navigationBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
        }
        navigationBar.leftItem = .init(
            image: UIImage(resource: .chevronLeft),
            target: self,
            action: #selector(backDidTap)
        )
    }
}
