//
//  cameraViewController.swift
//  fourpin
//
//  Created by Jihaha kim on 2024/01/30.
//
import UIKit
import AVFoundation
import Photos
import Alamofire
import SnapKit

final class CameraViewController: BaseViewController {
    weak var delegate: CameraViewControllerDelegate?
    private let imagePicker = UIImagePickerController()
    private let cameraAuthButton = UIButton(type: .system)
    private let albumAuthButton = UIButton(type: .system)
    private let sendButton = UIButton(type: .system)
    private var selectedPhoto: UIImage?
    private var capturedPhoto: UIImage?
    private let baseUrl = "http://ec2-44-201-161-53.compute-1.amazonaws.com:8080/"
    private let imageView = UIImageView()
    private let bodyStackView:UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    private let containerView = UIView()
    private var initialLocation: CLLocation?
    private let pickedImage:UIImage
    private var locationString:String = ""
    private let dateLabel:UILabel = {
        let label = UILabel(frame: CGRect(x: 16, y: 17, width: 112, height: 17))
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        return label
    }()
    private let editButton: UIButton = {
        let button = UIButton()
        button.setTitle(Text.edit, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 12
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return button
    }()
    private let locationLabel:UILabel = {
        let label = UILabel(frame: CGRect(x: 16, y: 17, width: 112, height: 17))
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        return label
    }()
    private let navigationBar: PDSNavigationBar = {
        let navigationBar = PDSNavigationBar()
        return navigationBar
    }()
    private let rightButtonItem = PDSNavigationBarButtonItem(title: Text.save, target: self, action: #selector(sendAction))
    
    // MARK: - Setup
    
    override func setUpUI() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        let imageViewMargin: CGFloat = 20
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy.MM.dd"
        let currentDateString = dateFormatter.string(from: Date())
        //todo: 사진 metadata에서 날짜 가져올 수 있는지 확인
        dateLabel.text = currentDateString
        locationLabel.text = locationString
        navigationBar.title = locationString
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
        navigationBar.rightItem = rightButtonItem
        
        view.backgroundColor = .black
        self.imagePicker.delegate = self
        containerView.addSubview(imageView)
        containerView.addSubview(editButton)
        view.addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom).offset(imageViewMargin)
            make.centerX.equalToSuperview()
            make.width.equalTo(375)
            make.height.equalTo(150)
        }
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom).offset(imageViewMargin)
            make.centerX.equalToSuperview()
            make.width.equalTo(375)
            make.height.equalTo(150)
        }
        editButton.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview().inset(10)
            make.width.equalTo(50)
            make.height.equalTo(33)
        }
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        
        view.addSubview(bodyStackView)
        bodyStackView.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(imageViewMargin)
            make.centerX.equalToSuperview()
            make.width.equalTo(375)
            make.height.equalTo(60)
        }
        bodyStackView.addArrangedSubview(dateLabel)
        bodyStackView.addArrangedSubview(locationLabel)
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(bodyStackView.snp.bottom).offset(imageViewMargin)
            make.height.equalTo(17)
        }
        locationLabel.snp.makeConstraints { make in
            make.height.equalTo(17)
            make.top.equalTo(dateLabel.snp.bottom).offset(imageViewMargin)
        }
    }
    
    private let dependency: Dependency
    
    @objc
    private func backDidTap() {
        delegate?.requestCameraViewControllerBackDidTap(self)
    }
    
    @objc
    private func editButtonTapped() {
    }
    
    // MARK: - Initializer
    
    struct Dependency {
        let image: UIImage
        let locationString: String
    }
    
    init(dependency: Dependency) {
        self.dependency = dependency
        self.pickedImage = dependency.image
        self.locationString = dependency.locationString
        super.init()
        configureImageView(with: pickedImage)
    }

    private func configureImageView(with image: UIImage?) {
        guard let image = image else { return }
        //다중 선택되면 Ui요구 사항에 따라 (슬라이드 방식?) 변경
        imageView.image = image
    }
    
    private func cameraAuth() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted {
                print("권한 허용")
                self.openCamera()
            } else {
                print("권한 거부")
                self.showAlertAuth("카메라")
            }
        }
    }
    
    private func albumAuth() {
        switch PHPhotoLibrary.authorizationStatus() {
        case .denied:
            print("거부")
            self.showAlertAuth("앨범")
        case .authorized:
            print("허용")
            self.openAlbum()
        case .notDetermined, .restricted:
            print("아직 결정하지 않은 상태")
            PHPhotoLibrary.requestAuthorization { state in
                if state == .authorized {
                    self.openAlbum()
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        default:
            break
        }
    }
    
    @objc func sendAction() {
        CameraService.shared.sendAction(selectedPhoto: selectedPhoto, capturedPhoto: capturedPhoto, initialLocation: initialLocation, baseUrl: baseUrl)
    }
    
    private func showAlertAuth(
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
    
    private func openAlbum() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    private func openCamera() {
        DispatchQueue.main.async {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .camera
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    private func savePhotoToLibrary(image: UIImage) {
        PHPhotoLibrary.requestAuthorization { (status) in
            if status == .authorized {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                }) { (success, error) in
                    if success {
                        print("사진이 앨범에 저장되었습니다.")
                    } else if let error = error {
                        print("사진 저장 중 오류 발생: \(error.localizedDescription)")
                    }
                }
            } else {
                print("앨범 접근 권한이 거부되었습니다.")
            }
        }
    }
}

extension CameraViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            if picker.sourceType == .photoLibrary {
                selectedPhoto = image
            } else {
                capturedPhoto = image
            }
        }
    }
}

extension CameraViewController: UINavigationControllerDelegate {
}

extension UIImage {
    func toBase64() -> String? {
        guard let imageData = self.jpegData(compressionQuality: 0.1) else {
            return nil
        }
        return imageData.base64EncodedString()
    }
}

private extension CameraViewController {
    enum Text {
        static let edit = "수정"
        static let save = "저장"
    }
}

protocol CameraViewControllerDelegate: AnyObject {
    func requestCameraViewControllerBackDidTap(_ viewController: CameraViewController)
}
