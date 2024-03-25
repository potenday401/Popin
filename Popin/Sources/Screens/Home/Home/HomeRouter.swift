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
            //network injection appdelegate로 옮겨야함
            let network = AlamofireNetwork(configuration: sessionConfiguration)
            let cameraService = CameraService(network: network)
            let dependency = CameraViewController.Dependency(image: image, locationString: locationString, cameraService: cameraService)
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

private var sessionConfiguration: URLSessionConfiguration {
    #if DEBUG
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [PopinURLProtocolMock.self]
    PopinTestSupport.setUpURLProtocol()
    #else
    let configuration = URLSessionConfiguration.default
    #endif
    
    
    return configuration
}
