//
//  ProfileRouter.swift
//  Popin
//
//  Created by Jihaha kim on 2024/03/13.
//

import UIKit

protocol ProfileRouter {
    func routeToHome()
}

final class ProfileRouterImp: ProfileRouter {
    
    weak var viewController: UIViewController?

    func routeToHome() {
        DispatchQueue.main.async {
            let homeViewController = HomeViewController()
            self.viewController?.navigationController?.pushViewController(homeViewController, animated: true)
        }
    }
}
