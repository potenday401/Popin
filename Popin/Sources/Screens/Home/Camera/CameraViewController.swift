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
    private let containerView = UIView()
    private var initialLocation: CLLocation?
    private let pickedImage:[UIImage]
    private var locationString:String = ""
    private let dateLabel:UILabel = {
        let label = UILabel(frame: CGRect(x: 16, y: 17, width: 112, height: 17))
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        return label
    }()
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .leading
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        return stackView
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
    // MARK: - Setup
    
    private lazy var dateButton: UIButton = {
        let button = makeButton(title: "날짜 시간 정보", backgroundColor: .gray500, titleColor: .gray100)
        button.addTarget(self, action: #selector(dateButtonDidTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var placeButton: UIButton = {
        let button = makeButton(title: "장소", backgroundColor: .gray500, titleColor: .gray100)
        button.addTarget(self, action: #selector(placeButtonDidTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var uploadButton: UIButton = {
        let button = makeButton(title: "사진 등록하기", backgroundColor: .gray500, titleColor: .gray100)
        button.addTarget(self, action: #selector(uploadButtonDidTap), for: .touchUpInside)
        return button
    }()
    
    private func makeButton(title: String, backgroundColor: UIColor, titleColor:UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.backgroundColor = backgroundColor
        button.setTitle(title, for: .normal)
        button.setTitleColor(titleColor, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true
        button.layer.cornerRadius = 8
        return button
    }
    
    @objc
    func dateButtonDidTap() {
        
    }
    
    @objc
    func placeButtonDidTap() {
        
    }
    
    @objc
    func uploadButtonDidTap() {
        uploadPin()
    }
    override func setUpUI() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        let imageViewMargin: CGFloat = 20
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy.MM.dd"
        let currentDateString = dateFormatter.string(from: Date())
        //todo: 사진 metadata에서 날짜 가져올 수 있는지 확인
        dateLabel.text = currentDateString
        locationLabel.text = locationString
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
        
        view.backgroundColor = .black
        self.imagePicker.delegate = self
        containerView.addSubview(imageView)
        view.addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom).offset(imageViewMargin)
            make.centerX.equalToSuperview()
            make.width.equalTo(375)
            make.height.equalTo(118)
        }
        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = true
        scrollView.backgroundColor = .black
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(scrollView)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        
        scrollView.addSubview(stackView)
        
        // 실제 이미지 데이터로 변경 필요함
        let numberOfColumns = 10
        let numberOfRows = 1
        
        for _ in 0..<numberOfRows {
            let rowView = UIStackView()
            rowView.axis = .horizontal
            rowView.distribution = .fillEqually
            rowView.spacing = 0
            
            for columnIndex in 0..<numberOfColumns {
                let iconView = UIView()
                var imageUrl:URL?
                
                    imageUrl = URL(string: "https://picsum.photos/200/200")!
                var imageView: UIImageView = {
                    let imageView = UIImageView()
                    imageView.contentMode = .scaleAspectFit
                    imageView.kf.setImage(with: imageUrl)
                    return imageView
                }()
                
                iconView.addSubview(imageView)
                imageView.snp.makeConstraints { make in
                    make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
                    make.width.equalTo(118)
                    make.height.equalTo(118)
                }
                imageView.layer.cornerRadius = 12
                imageView.layer.masksToBounds = true
                
//                let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(iconViewTapped(_:)))
//                iconView.addGestureRecognizer(tapGestureRecognizer)
                iconView.isUserInteractionEnabled = true
                
                rowView.addArrangedSubview(iconView)
            }
            
            stackView.addArrangedSubview(rowView)
        }
        
        scrollView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(navigationBar.snp.bottom).offset(8)
        }
        stackView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        scrollView.contentSize = CGSize(width: stackView.frame.size.width, height: stackView.frame.size.height)
        view.addSubview(buttonStackView)
        buttonStackView.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.bottom).offset(36)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        dateButton.snp.makeConstraints { make in
            make.height.equalTo(62)
            make.width.equalTo(343)
        }
        
        placeButton.snp.makeConstraints { make in
            make.height.equalTo(62)
            make.width.equalTo(343)
        }
        
        uploadButton.snp.makeConstraints { make in
            make.height.equalTo(56)
            make.width.equalTo(343)
        }
        
        buttonStackView.axis = .vertical
        buttonStackView.addArrangedSubview(dateButton)
        buttonStackView.addArrangedSubview(placeButton)
        buttonStackView.addArrangedSubview(uploadButton)
        buttonStackView.setCustomSpacing(291, after: placeButton)
        [dateButton, placeButton, uploadButton].forEach(buttonStackView.addArrangedSubview(_:))

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
        let image: [UIImage]
        let locationString: String
        let cameraService: CameraServiceProtocol
    }
    
    init(dependency: Dependency) {
        self.dependency = dependency
        self.pickedImage = dependency.image
        self.locationString = dependency.locationString
        super.init()
        configureImageView(with: pickedImage)
    }
    
    private func configureImageView(with images: [UIImage]?) {
        guard let images = images else { return }

        let scrollView = UIScrollView()
        scrollView.frame = imageView.bounds
        scrollView.isPagingEnabled = true

        for (index, image) in images.enumerated() {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            imageView.frame = CGRect(x: scrollView.frame.width * CGFloat(index), y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
            scrollView.addSubview(imageView)
        }

        scrollView.contentSize = CGSize(width: scrollView.frame.width * CGFloat(images.count), height: scrollView.frame.height)
        self.view.addSubview(scrollView)
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
    
    @objc func uploadPin() {
        dependency.cameraService.uploadPin(selectedPhoto: selectedPhoto, capturedPhoto: capturedPhoto, initialLocation: initialLocation) { result in
            switch result {
            case .success(let response):
                print("업로드 성공: \(response)")
            case .failure(let error):
                print("업로드 실패: \(CameraError.failUpload)")
            }
        }
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

