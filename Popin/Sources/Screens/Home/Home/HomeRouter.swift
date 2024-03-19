//  HomeRouter.swift
//  Popin
//
//  Created by Jihaha kim on 2024/03/13.
//
import UIKit

protocol HomeRouter {
    func routeToHomeMapView()
    func routeToCameraView(with image: UIImage, locationString: String)
    func routeToEditProfile()
    func dismissFromProfileScreen()
    func dismissFromCameraScreen()
}

final class HomeRouterImp: HomeRouter, ProfileViewControllerDelegate, CameraViewControllerDelegate {
    func requestCameraViewControllerBackDidTap(_ viewController: CameraViewController) {
        self.dismissFromCameraScreen()
    }
    
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

    func routeToCameraView(with image: UIImage, locationString: String) {
        DispatchQueue.main.async {
            let dependency = CameraViewController.Dependency(image: image, locationString: locationString)
            let cameraViewController = CameraViewController(dependency: dependency)
            cameraViewController.delegate = self
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
    func dismissFromCameraScreen() {
        DispatchQueue.main.async {
            self.viewController?.navigationController?.popViewController(animated: true)        }
    }
}
