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

class CameraViewController: BaseViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()
    let cameraAuthButton = UIButton(type: .system)
    let albumAuthButton = UIButton(type: .system)
    let sendButton = UIButton(type: .system)
    var selectedPhoto: UIImage?
    var capturedPhoto: UIImage?
    let baseUrl = "http://ec2-44-201-161-53.compute-1.amazonaws.com:8080/"
    let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 400, height: 150))
    var initialLocation: CLLocation?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        self.imagePicker.delegate = self
        setupButtons()
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.topItem?.title = "뒤로 가기"
    }
    let locationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 0
        label.text = "Default Location"
        return label
    }()
   
    let headerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 0
        return stack
    }()
    
    let bodyStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 0
        return stack
    }()
    
    private func setupButtons() {
        sendButton.setTitle("내 추억 '핀하기'", for: .normal)
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        sendButton.setTitleColor(.white, for: .normal)

        albumAuthButton.setTitle("내 추억 불러오기", for: .normal)
        albumAuthButton.addTarget(self, action: #selector(albumAuthButtonTapped), for: .touchUpInside)
        albumAuthButton.setTitleColor(.white, for: .normal)

        cameraAuthButton.setTitle("추억 찍기", for: .normal)
        cameraAuthButton.setTitleColor(.white, for: .normal)
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        headerStackView.addArrangedSubview(sendButton)
        headerStackView.addArrangedSubview(albumAuthButton)
        headerStackView.translatesAutoresizingMaskIntoConstraints = false
        bodyStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerStackView)
        view.addSubview(bodyStackView)
        
        NSLayoutConstraint.activate([
                headerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                headerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                headerStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                headerStackView.heightAnchor.constraint(equalToConstant: 50),
                bodyStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                bodyStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                bodyStackView.topAnchor.constraint(equalTo: headerStackView.bottomAnchor),
                bodyStackView.heightAnchor.constraint(equalToConstant: 250),
            ])
        
    }
   
    private func setupImageView() {
            guard let image = selectedPhoto ?? capturedPhoto else {
                return
            }

        imageView.contentMode = .scaleAspectFit
            imageView.image = image
            imageView.clipsToBounds = true
            bodyStackView.addSubview(imageView)
            imageView.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                imageView.heightAnchor.constraint(equalToConstant: 150),
                imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
                imageView.topAnchor.constraint(equalTo: headerStackView.bottomAnchor),
            ])

            setupLocationLabel()
        }


    private func setupLocationLabel() {
            locationLabel.textColor = .white
            locationLabel.textAlignment = .center
            locationLabel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(locationLabel)

        NSLayoutConstraint.activate([
            locationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            locationLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            locationLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            locationLabel.heightAnchor.constraint(equalToConstant: 150),
            locationLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
    }
    
    func updateLocationLabel(with annotation: CLLocation) {
        let location = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)

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

                self.locationLabel.text = locationString.isEmpty ? "Unknown Location" : locationString
            } else {
                self.locationLabel.text = "Unknown Location"
            }
        }
    }





    // 카메라 권한 확인 버튼 액션
    @objc private func cameraAuthButtonTapped() {
        cameraAuth()
    }
    
    // 앨범 권한 확인 버튼 액션
    @objc private func albumAuthButtonTapped() {
        albumAuth()
    }
    
    // 전송 버튼 액션
    @objc private func sendButtonTapped() {
        print("tab?")
        sendAction()
    }
    
    /**
     카메라 접근 권한 판별하는 함수
     */
    func cameraAuth() {
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
    
    /**
     앨범 접근 권한 판별하는 함수
     */
    func albumAuth() {
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
    
    func sendAction() {
        guard let base64String = selectedPhoto?.toBase64() ?? capturedPhoto?.toBase64() else {
            print("Image is nil.")
            return
        }
        let parameters: Parameters = [
            "latLng": [
                "latitude": initialLocation?.coordinate.latitude,
                "longitude": initialLocation?.coordinate.longitude
            ],
            "memberId": "1245",
            "locality": "316",
            "subLocality": "136171",
            "photoDateTime": 0,
            "photoFileBase64Payload": base64String,
            "photoFileExt": "jpg",
            "photoPinId": "1246",
            "tagIds": [
                "1234646"
            ]
        ]
        AF.session.configuration.timeoutIntervalForRequest = 60
        AF.request(baseUrl+"photo-pins", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: ["Content-Type":"application/json", "Accept":"application/json"]).responseData() { response in
            debugPrint(response)

            switch response.result {
            case .success:
                if let data = response.data, let jsonString = String(data: data, encoding: .utf8) {
                    print("Response Data: \(jsonString)")
                }

                if let jsonObject = try? response.result.get() as? [String: Any] {
                    print("Object: \(jsonObject)")
                    let result = jsonObject["result"] as? String
                    print("요청결과: \(result!)")
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }



    /**
     권한을 거부했을 때 띄어주는 Alert 함수
     - Parameters:
     - type: 권한 종류
     */
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
    
    /**
     아이폰에서 앨범에 접근하는 함수
     */
    func openAlbum() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }

    // "카메라" 버튼을 눌렀을 때의 처리
    func openCamera() {
        DispatchQueue.main.async {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .camera
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }

    
    /**
     UIImagePickerControllerDelegate에 정의된 메소드 - 선택한 미디어의 정보를 알 수 있음
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            if picker.sourceType == .photoLibrary {
                selectedPhoto = image
            } else {
                capturedPhoto = image
            }
            
            setupImageView()
        }
    }

    
    func savePhotoToLibrary(image: UIImage) {
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

extension UIImage {
    func toBase64() -> String? {
        guard let imageData = self.jpegData(compressionQuality: 0.1) else {
            return nil
        }
        return imageData.base64EncodedString()
    }
}



