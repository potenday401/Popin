//
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

//Mark - todo: 태그, 날짜뷰 추가시 탭 네비게이션 사용
//class HomeViewController: TabmanViewController {
class HomeViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, HomeMapViewControllerDelegate {
    func didSelectLocation(annotations: [CustomImageAnnotation]) {
        let albumViewController = AlbumViewController()
        albumViewController.annotations = annotations
        navigationController?.pushViewController(albumViewController, animated: true)
      }
    
    private let homeMapViewController = HomeMapViewController()
    private var viewControllers: [UIViewController] = []
    
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
        
        let leftImageView = UIImageView(image: UIImage(resource: .cameraButton))
        let cameraButton = UIButton()
        cameraButton.setImage(UIImage(resource: .cameraButton), for: .normal)
        cameraButton.addTarget(self, action: #selector(cameraShootButtonTapped), for: .touchUpInside)

        let leftItem = PDSNavigationBarItem()
            leftItem.addSubview(cameraButton)
            cameraButton.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.size.equalTo(CGSize(width: 24, height: 24))
                make.left.equalToSuperview().offset(12)
            }
            cameraButton.contentMode = .scaleAspectFit
            navigationBar.leftItem = leftItem

        let rightImageView = UIImageView(image: UIImage(resource: .profileButton))
        let rightItem = PDSNavigationBarItem()
        rightItem.addSubview(rightImageView)
        rightImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 24, height: 24))
            make.right.equalToSuperview().offset(-12)
        }
        rightImageView.contentMode = .scaleAspectFit
        navigationBar.rightItem = rightItem
        
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
        label.text = "일본..."
        label.lineBreakMode = .byWordWrapping
        label.font = .systemFont(ofSize: 26, weight: .medium)
        return label
    }()
    
    @objc private func cameraShootButtonTapped() {
        cameraAuth()
    }
    
    @objc private func cameraUploadButtonTapped() {
        let cameraViewController = CameraViewController()
        navigationController?.pushViewController(cameraViewController, animated: true)
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
        //        let dateViewController = DateViewController(viewModel: nil)

//        let navigationController = UINavigationController(rootViewController: homeMapViewController)
//        viewControllers.append(navigationController)
////        viewControllers.append(homeMapViewController)
//        viewControllers.append(dateViewController)
//
//        let bar = TMBar.ButtonBar()
//
//        addBar(bar, dataSource: self, at: .top)
//        bar.layout.transitionStyle = .snap
//        bar.layout.contentMode = .fit
//        bar.backgroundView.style = .clear
//        bar.backgroundColor = .black
//        bar.buttons.customize { (button) in
//            button.tintColor = .gray
//            button.selectedTintColor = .white
//        }
//        bar.indicator.tintColor = .clear
//        dataSource = self

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
//            todo: 반응형(다른 기기 확인)
            make.top.equalTo(recentMemoryStack.snp.bottom).offset(-70)
        }
        
        cameraButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-0.12 * view.bounds.height)
        }
    }
    func didSelectLocation() {
          // 선택된 위치에 대한 동작 수행
          let albumViewController = AlbumViewController()
          navigationController?.pushViewController(albumViewController, animated: true)
      }
}

//extension HomeViewController: PageboyViewControllerDataSource {
//    
//    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
//        return viewControllers.count
//    }
//    
//    func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
//        return viewControllers[index]
//    }
//    
//    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
//        return nil
//    }
//}

// MARK: - TMBarDataSource

extension HomeViewController: TMBarDataSource {
    
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        let title = index == 0 ? "지도뷰" : "날짜뷰"
        return TMBarItem(title: title)
    }
}

private extension HomeViewController {

    enum Text {
        static let recentMemoryTitle = "최근 업로드 된 추억"
        static let uploadPhotoTitle = "사진등록하기"
    }
}

//protocol HomeMapViewControllerDelegate: AnyObject {
//    func didSelectLocation()
//}

protocol HomeMapViewControllerDelegate: AnyObject {
  func didSelectLocation(annotations: [CustomImageAnnotation])
}


//#Preview {
//     HomeViewController()
//}
