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
    func dismissFromProfileScreen()
}

final class HomeRouterImp: HomeRouter, ProfileViewControllerDelegate {
    func requestProfileViewControllerBackDidTap(_ viewController: ProfileViewController) {
        self.dismissFromProfileScreen()
    }
    
    
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
            profileViewController.delegate = self
            self.viewController?.navigationController?.pushViewController( profileViewController, animated: true)
        }
    }
    
    func dismissFromProfileScreen() {
        DispatchQueue.main.async {
            self.viewController?.navigationController?.popViewController(animated: true)        }
    }
}
