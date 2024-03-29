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
import PhotosUI
import CoreLocation

final class HomeViewController: BaseViewController, HomeMapViewControllerDelegate {
    func didSelectLocation(annotations: [CustomImageAnnotation]) {
        let albumViewController = AlbumViewController()
        albumViewController.annotations = annotations
        navigationController?.pushViewController(albumViewController, animated: true)
    }
    var router: HomeRouter?
    private let homeMapViewController = HomeMapViewController()
    private let locationManager = CLLocationManager()
    private var locationString:String = ""
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
    
    func albumAuth() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 5

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }

    func openAlbum() {
        DispatchQueue.main.async {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    
    func showAlertAuth(
        _ type: String
    ) {
        if let appName = Bundle.main.infoDictionary!["CFBundleDisplayName"] as? String {
            let alertVC = UIAlertController(
                title: "설정",
                message: "\(appName)이(가) \(type) 접근 허용되어 있지 않습니다. 설정화면으로 가시겠습니까?",
                preferredStyle: .alert
            )
            let cancelAction = UIAlertAction(
                title: "취소",
                style: .cancel,
                handler: nil
            )
            let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
            }
            alertVC.addAction(cancelAction)
            alertVC.addAction(confirmAction)
            self.present(alertVC, animated: true, completion: nil)
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
        albumAuth()
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
                self.locationString = locationString.isEmpty ? "Unknown Location" : locationString
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

extension HomeViewController: CameraViewControllerDelegate {
    func requestCameraViewControllerBackDidTap(_ viewController: CameraViewController) {
        router?.dismissFromCameraScreen()
    }
}

extension HomeViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            picker.dismiss(animated: true, completion: nil)
            
            guard let image = info[.originalImage] as? UIImage else {
                print("Failed to pick an image")
                return
            }
            router?.routeToCameraView(with: image, locationString: locationString)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
            print("취소")
        }
}

extension HomeViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)

        var selectedImages: [UIImage] = []
        let dispatchGroup = DispatchGroup()

        for result in results {
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                dispatchGroup.enter()
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    if let image = image as? UIImage {
                        selectedImages.append(image)
                    }
                    dispatchGroup.leave()
                }
            }
        }
        dispatchGroup.notify(queue: .main) {
            self.handleSelectedImages(selectedImages)
        }
    }


    func handleSelectedImages(_ images: [UIImage]) {
        guard let singleImage = images.first else {
            print("No image selected")
            return
        }
        router?.routeToCameraView(with: singleImage, locationString: locationString)
    }
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
