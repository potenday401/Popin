//
//  ProfileRouter.swift
//  Popin
//
//  Created by Jihaha kim on 2024/03/13.
//

import UIKit

protocol ProfileRouter {
    func routeToEditProfile()
}

final class ProfileRouterImp: ProfileRouter {
    
    weak var viewController: UIViewController?

    func routeToEditProfile() {
        DispatchQueue.main.async {
            let editProfileViewController = HomeViewController()
            self.viewController?.navigationController?.pushViewController(editProfileViewController, animated: true)
        }
    }
    // Implement other navigation methods for the profile screen
}
