//  HomeViewController.swift
//  fourpin
//
//  Created by Jihaha kim on 2024/01/30.
//

import UIKit
import Tabman
import Pageboy
import SnapKit
import Photos
import CoreLocation

final class HomeViewController: BaseViewController, HomeMapViewControllerDelegate {
    func didSelectLocation(annotations: [CustomImageAnnotation]) {
        let albumViewController = AlbumViewController()
        albumViewController.annotations = annotations
        navigationController?.pushViewController(albumViewController, animated: true)
    }
    private var router: HomeRouter?
    private let homeMapViewController = HomeMapViewController()
    private let locationManager = CLLocationManager()
    
    func cameraAuth() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted {
                print("권한 허용")
                self.openCamera()
            } else {
                print("권한 거부")
            }
        }
    }
    
    func openCamera() {
        DispatchQueue.main.async {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePickerController = UIImagePickerController()
                imagePickerController.delegate = self
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            } else {
                print("Camera not available")
            }
        }
    }
    
    
    private let navigationBar: PDSNavigationBar = {
        let navigationBar = PDSNavigationBar()
        navigationBar.titleView = UIImageView(image: UIImage(resource: .logo))
        return navigationBar
    }()
    private let recentMemoryStack:UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 6
        return stackView
    }()
    private let recentMemoryLabel:UILabel = {
        let label = UILabel(frame: CGRect(x: 16, y: 17, width: 112, height: 17))
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .gray100
        label.text = Text.recentMemoryTitle
        return label
    }()
    
    private let recentPinLabel:UILabel = {
        let label = UILabel(frame: CGRect(x: 16, y: 50, width: 112, height: 50))
        label.textColor = .white
        label.text = ""
        label.lineBreakMode = .byWordWrapping
        label.font = .systemFont(ofSize: 26, weight: .medium)
        return label
    }()
    
    @objc private func cameraShootButtonTapped() {
        cameraAuth()
    }
    
    @objc private func moveToProfileScreen() {
        router?.routeToEditProfile()
    }
    
    @objc private func cameraUploadButtonTapped() {
        router?.routeToCameraView()
    }
    
    private lazy var cameraButton: UIButton = {
        let button = makeButton(title: Text.uploadPhotoTitle)
        button.addTarget(self, action: #selector(cameraUploadButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private func makeButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.backgroundColor = .indigo200
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 343).isActive = true
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true
        button.layer.cornerRadius = 8
        return button
    }
    
    override func viewDidLoad() {
        homeMapViewController.delegate = self
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        navigationBar.leftItem = .init(
            image: UIImage(resource: .cameraButton),
            target: self,
            action: #selector(cameraShootButtonTapped)
        )
        
        navigationBar.rightItem = .init(
            image: UIImage(resource: .profileButton),
            target: self,
            action: #selector(moveToProfileScreen)
        )
        
        view.addSubview(cameraButton)
        view.addSubview(navigationBar)
        
        navigationBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
        }
        
        view.addSubview(recentMemoryStack)
        view.addSubview(homeMapViewController.view)
        recentMemoryStack.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom).offset(42)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(54)
        }
        
        recentMemoryStack.addArrangedSubview(recentMemoryLabel)
        recentMemoryLabel.snp.makeConstraints { make in
            make.height.equalTo(17)
        }
        recentMemoryStack.addArrangedSubview(recentPinLabel)
        recentPinLabel.snp.makeConstraints { make in
            make.height.equalTo(31)
        }
        
        homeMapViewController.view.snp.makeConstraints { make in
            make.height.equalTo(359)
            make.top.equalTo(recentMemoryStack.snp.bottom).offset(0)
        }
        
        cameraButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(homeMapViewController.view.snp.bottom).offset(54)
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        updateLocationLabel(latitude, longitude)
    }
    
    func updateLocationLabel(_ latitude: CLLocationDegrees, _ longitude: CLLocationDegrees) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let placemark = placemarks?.first {
                var locationString = ""
                
                if let locality = placemark.locality {
                    locationString += locality
                }
                
                if let sublocality = placemark.subLocality {
                    if !locationString.isEmpty {
                        locationString += ", "
                    }
                    locationString += sublocality
                }
                
                self.recentPinLabel.text = locationString.isEmpty ? "Unknown Location" : locationString
            } else {
                self.recentPinLabel.text = "Unknown Location"
            }
        }
    }
    
    func didSelectLocation() {
        router?.routeToHomeMapView()
    }
}

private extension HomeViewController {
    
    enum Text {
        static let recentMemoryTitle = "최근 업로드 된 추억"
        static let uploadPhotoTitle = "사진등록하기"
    }
}

extension HomeViewController: ProfileViewControllerDelegate {
    func requestProfileViewControllerBackDidTap(_ viewController: ProfileViewController) {
        router?.dismissFromProfileScreen()
    }
}

extension HomeViewController: UIImagePickerControllerDelegate {
}

extension HomeViewController: UINavigationControllerDelegate {
}

extension HomeViewController: CLLocationManagerDelegate {
}

protocol HomeMapViewControllerDelegate: AnyObject {
    func didSelectLocation(annotations: [CustomImageAnnotation])
}


//#Preview {
//     HomeViewController()
//}
