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
import MapKit
import Kingfisher

final class CameraViewController: BaseViewController, LocationSearchControllerDelegate {
    var imageDataHandler: (([ImageData]) -> Void)?
    private func sendImageDataToAlbumDetailViewController() {
        guard let imageDataHandler = imageDataHandler else { return }
        imageDataHandler(imageData)
    }
    weak var delegate: CameraViewControllerDelegate?
    private let imagePicker = UIImagePickerController()
    private let cameraAuthButton = UIButton(type: .system)
    private let albumAuthButton = UIButton(type: .system)
    private let sendButton = UIButton(type: .system)
    private var selectedPhoto: UIImage?
    private var capturedPhoto: UIImage?
    private let imageView = UIImageView()
    private let containerView = UIView()
    private let pickedImage:[UIImage]
    private var locationString:String = ""
    private var location:CLLocation?
    private var imageData: [ImageData] = []
    private let accessToken:String
    private let searchCompleter = MKLocalSearchCompleter()
    private var selectedLocation = ""
    private var contentId:Int = 0
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .leading
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        return stackView
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
    // todo: 지도에도 게시물 보이게 반영 필요함
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
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy · HH시mm분"
        let formattedDate = dateFormatter.string(from: currentDate)
        dateButton.setTitle(formattedDate, for: .normal)
    }
    
    @objc
    func placeButtonDidTap() {
        let locationSearchController = LocationSearchController()
        locationSearchController.delegate = self
        selectedLocation = ""
        self.navigationController?.pushViewController(locationSearchController, animated: true)
    }
    
    func didSelectLocation(_ location: String) {
        selectedLocation = location
        updatePlaceButtonTitle()
    }
    
    private func updatePlaceButtonTitle() {
        if selectedLocation.isEmpty {
            placeButton.setTitle("장소", for: .normal)
        } else {
            placeButton.setTitle(selectedLocation, for: .normal)
        }
    }
    
    @objc
    func uploadButtonDidTap() {
        let currentDateString = currentDate()
        let bodyData: [String: Any] = [
            "title": "string",
            "address": "\(selectedLocation)",
            "latitude": location?.coordinate.latitude,
            "longitude": location?.coordinate.longitude,
            "memorizedAt": currentDateString
        ]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: bodyData) else {
            print("Failed to convert JSON data")
            return
        }
        uploadContent(body: jsonData, accessToken: accessToken) { result in
            switch result {
            case .success(let contentId):
                DispatchQueue.main.async {
                    self.uploadPin(contentId: contentId, currentDateString: currentDateString)
                }
            case .failure(let error):
                print("Failed to upload content: \(error)")
            }
        }
    }
    
    private func currentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        return dateFormatter.string(from: Date())
    }
    
    override func setUpUI() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationItem.hidesBackButton = true
        let imageViewMargin: CGFloat = 20
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
        
        let numberOfRows = 1
        let numberOfColumns = Int(ceil(Double(dependency.image.count) / Double(numberOfRows)))
        
        for _ in 0..<numberOfRows {
            let rowView = UIStackView()
            rowView.axis = .horizontal
            rowView.distribution = .fillEqually
            rowView.spacing = 0
            
            for columnIndex in 0..<numberOfColumns {
                let iconView = UIView()
                guard columnIndex < dependency.image.count else { continue }
                let image = dependency.image[columnIndex]
                
                var imageView: UIImageView = {
                    let imageView = UIImageView()
                    imageView.contentMode = .scaleAspectFit
                    return imageView
                }()
                
                imageView.image = image
                
                iconView.addSubview(imageView)
                imageView.snp.makeConstraints { make in
                    make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
                    make.width.equalTo(100)
                    make.height.equalTo(100)
                }
                imageView.layer.cornerRadius = 24
                imageView.layer.masksToBounds = true
                
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
    
    private func updateLabels() {
        guard let firstImageData = imageData.first else { return }
        if let creationDate = firstImageData.creationDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yy.MM.dd"
            dateButton.setTitle(dateFormatter.string(from: firstImageData.creationDate ?? Date()), for: .normal)
        }
        
        if let location = firstImageData.location {
            placeButton.setTitle(selectedLocation.isEmpty ? "장소" : selectedLocation, for: .normal)
        }
    }
    
    // MARK: - Initializer
    
    struct Dependency {
        let image: [UIImage]
        let locationString: String
        let ImageData: [ImageData]
        let accessToken: String
        let cameraService: CameraServiceProtocol
        let location: CLLocation
    }
    
    init(dependency: Dependency) {
        self.dependency = dependency
        self.pickedImage = dependency.image
        self.imageData = dependency.ImageData
        self.accessToken = dependency.accessToken
        self.locationString = dependency.locationString
        self.location = dependency.location
        super.init()
        configureImageView(with: pickedImage)
        updateLabels()
    }
    
    private func configureImageView(with images: [UIImage]) {
        guard !images.isEmpty else { return }
        
        let scrollView = UIScrollView()
        scrollView.frame = imageView.bounds
        scrollView.isPagingEnabled = true
        
        for (index, data) in images.enumerated() {
            let imageView = UIImageView(image: data)
            imageView.contentMode = .scaleAspectFit
            
            
            imageView.frame = CGRect(x: scrollView.frame.width * CGFloat(index), y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
            scrollView.addSubview(imageView)
        }
        
        scrollView.contentSize = CGSize(width: scrollView.frame.width * CGFloat(imageData.count), height: scrollView.frame.height)
        self.view.addSubview(scrollView)
        sendImageDataToAlbumDetailViewController()
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
    
    func uploadContent(body: Data, accessToken: String, completion: @escaping (Result<Int, Error>) -> Void) {
        let url = Endpoint.Pin.uploadContent.contentUrl
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                //                completion(.failure(CameraError.invalidResponse))
                return
            }
            
            guard 200..<300 ~= httpResponse.statusCode else {
                print(httpResponse.statusCode, "code check")
                //                completion(.failure(CameraError.invalidStatusCode(httpResponse.statusCode)))
                return
            }
            
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let responseData = json["responseData"] as? [String: Any],
                       let contentId = responseData["contentId"] as? Int {
                        completion(.success(contentId))
                    } else {
                        //                        completion(.failure(CameraError.contentIdNotFound))
                    }
                } catch {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    @objc func uploadPin(contentId: Int, currentDateString: String) {
        dependency.cameraService.uploadPin(selectedPhoto: dependency.image, capturedPhoto: dependency.image, initialLocation: location, accessToken: accessToken, contentId: contentId, currentDateString: currentDateString) { result in
            switch result {
            case .success(let response):
                NotificationCenter.default.post(name: .uploadDidFinish, object: nil)
                self.delegate?.requestCameraViewControllerBackDidTap(self)
            case .failure(let error):
                print(error, "errorcheck")
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

private extension CameraViewController {
    enum Text {
        static let edit = "수정"
        static let save = "저장"
    }
}

protocol CameraViewControllerDelegate: AnyObject {
    func requestCameraViewControllerBackDidTap(_ viewController: CameraViewController)
}
