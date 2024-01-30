//
//  cameraViewController.swift
//  fourpin
//
//  Created by Jihaha kim on 2024/01/30.
//
import UIKit
import AVFoundation
import Photos

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var captureSession: AVCaptureSession?
    var photoOutput: AVCapturePhotoOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        // 카메라 뷰 생성
        captureSession = AVCaptureSession()
        guard let captureDevice = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: captureDevice)
        else {
            print("카메라를 초기화하는데 실패하였습니다.")
            return
        }
        
        captureSession?.addInput(input)
        
        // 프리뷰 레이어 설정
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer?.frame = view.bounds
        view.layer.addSublayer(previewLayer!)
        
        // 사진을 찍을 수 있는 기능 추가
        photoOutput = AVCapturePhotoOutput()
        captureSession?.addOutput(photoOutput!)
        
        captureSession?.startRunning()
    }
    
    // 사진 찍기 버튼을 눌렀을 때 호출되는 메소드
    @IBAction func takePhotoButtonTapped(_ sender: UIButton) {
        guard let photoOutput = self.photoOutput else {
            return
        }
        
        let photoSettings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    // 사진 캡처가 완료되었을 때 호출되는 메소드
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation(),
           let image = UIImage(data: imageData) {
            print(image, "capture image")
        }
    }
    
    // 갤러리에서 사진을 선택하는 버튼을 눌렀을 때 호출되는 메소드
    @IBAction func chooseFromGalleryButtonTapped(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    // 갤러리에서 사진 선택이 완료되었을 때 호출되는 메소드
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            // 선택한 사진을 사용하여 원하는 동작 수행
            // 예: 사진 저장, 필터 적용 등
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    // 갤러리에서 사진 선택이 취소되었을 때 호출되는 메소드
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // 갤러리 접근 권한 요청
    func requestGalleryPermission() {
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized:
                // 권한 허용됨
                DispatchQueue.main.async {
                    // 갤러리에서 사진을 가져올 수 있는 버튼을 활성화
                    // 예: chooseFromGalleryButton.isEnabled = true
                }
            case .denied, .restricted, .notDetermined:
                // 권한 거부됨 또는 설정에서 제한됨
                DispatchQueue.main.async {
                    // 갤러리에서 사진을 가져올 수 있는 버튼을 비활성화
                    // 예: chooseFromGalleryButton.isEnabled = false
                }
            @unknown default:
                break
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 앱이 실행되면 갤러리 접근 권한을 확인하고 요청
        requestGalleryPermission()
    }
}
