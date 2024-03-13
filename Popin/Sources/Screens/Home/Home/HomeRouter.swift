//
//  HomeRouter.swift
//  Popin
//
//  Created by Jihaha kim on 2024/03/13.
//
import UIKit

protocol HomeRouter {
    func routeToHomeMapView()
    func routeToCameraView()
    func routeToEditProfile()
}

final class HomeRouterImp: HomeRouter {
    
    weak var viewController: UIViewController?

    func routeToHomeMapView() {
        DispatchQueue.main.async {
            let homeMapViewController = HomeMapViewController()
            
            self.viewController?.navigationController?.pushViewController(homeMapViewController, animated: true)
        }
    }
    
    func routeToCameraView() {
        DispatchQueue.main.async {
            let cameraViewController = CameraViewController()
            self.viewController?.navigationController?.pushViewController(cameraViewController, animated: true)
        }
    }
    
    func routeToEditProfile() {
        DispatchQueue.main.async {
            let profileViewController = ProfileViewController()
            self.viewController?.navigationController?.pushViewController(profileViewController, animated: true)
            
        }
    }
}
