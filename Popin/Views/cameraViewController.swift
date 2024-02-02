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

class CameraViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()
    let cameraAuthButton = UIButton(type: .system)
    let albumAuthButton = UIButton(type: .system)
    let sendButton = UIButton(type: .system)
    var selectedPhoto: UIImage?
    var capturedPhoto: UIImage?
    let baseUrl = "http://ec2-44-201-161-53.compute-1.amazonaws.com:8080/"
    let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.imagePicker.delegate = self
        setupButtons()
    }
    private func setupButtons() {
        cameraAuthButton.setTitle("카메라 버튼", for: .normal)
        cameraAuthButton.addTarget(self, action: #selector(cameraAuthButtonTapped), for: .touchUpInside)
        
        albumAuthButton.setTitle("앨범 버튼", for: .normal)
        albumAuthButton.addTarget(self, action: #selector(albumAuthButtonTapped), for: .touchUpInside)
        
        sendButton.setTitle("전송 버튼", for: .normal)
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [cameraAuthButton, albumAuthButton, sendButton])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
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

        let parameters: [String: Any] = [
            "latLng": [
                "latitude": 0,
                "longitude": 0
            ],
            "memberId": "string",
            "photoDateTime": 0,
            "photoFileBase64Payload": base64String,
            "photoFileExt": "string",
            "photoPinId": "string",
            "tagIds": [
                "string"
            ]
        ]
        
        let uploadURL = baseUrl + "photo-pins"
        AF.session.configuration.timeoutIntervalForRequest = 10

        AF.request(uploadURL, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).validate(statusCode: 200..<600).responseData() { response in
            switch response.result {
            case .success:
                if let data = response.data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        print("Response JSON: \(json)")
                    } catch {
                        print("Error parsing JSON: \(error)")
                    }
                } else {
                    print("Response data is nil.")
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
                // 앨범에서 선택한 사진을 selectedPhoto 변수에 저장합니다.
            } else {
                capturedPhoto = image
                imageView.contentMode = .scaleAspectFit
                imageView.image = capturedPhoto
                view.addSubview(imageView)
                // 카메라로 찍은 사진을 capturedPhoto 변수에 저장합니다... 안되고있음
            }
            imageView.contentMode = .scaleAspectFit
            imageView.image = selectedPhoto
            view.addSubview(imageView)
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



