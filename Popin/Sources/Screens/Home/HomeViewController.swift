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

class HomeViewController: TabmanViewController {
    
    private var viewControllers: [UIViewController] = []
    
    private let navigationBar: PDSNavigationBar = {
        let navigationBar = PDSNavigationBar()
        navigationBar.titleView = UIImageView(image: UIImage(resource: .logo))
        
        let leftImageView = UIImageView(image: UIImage(resource: .cameraButton))
        let leftItem = PDSNavigationBarItem()
        leftItem.addSubview(leftImageView)
        leftImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 24, height: 24))
            make.left.equalToSuperview().offset(12)
        }
        leftImageView.contentMode = .scaleAspectFit
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

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dateViewController = DateViewController(viewModel: nil)
        let homeMapViewController = HomeMapViewController()
        
        viewControllers.append(homeMapViewController)
        viewControllers.append(dateViewController)
        
        let bar = TMBar.ButtonBar()
        
        //  Mark - todo: 태그, 날짜뷰 추가시 탭 네비게이션 사용
        //  addBar(bar, dataSource: self, at: .top)
        bar.layout.transitionStyle = .snap
        bar.layout.contentMode = .fit
        bar.backgroundView.style = .clear
        bar.backgroundColor = .black
        bar.buttons.customize { (button) in
            button.tintColor = .gray
            button.selectedTintColor = .white
        }
        
        bar.indicator.tintColor = .clear
        dataSource = self
        
        let cameraButton = UIButton(type: .system)
        cameraButton.setTitle("사진등록하기", for: .normal)
        cameraButton.setTitleColor(.white, for: .normal)
        cameraButton.addTarget(self, action: #selector(cameraButtonTapped), for: .touchUpInside)
        
        view.addSubview(cameraButton)
        view.addSubview(navigationBar)
        
        navigationBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
        }
        
        cameraButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }
    }
    @objc private func cameraButtonTapped() {
        let cameraViewController = CameraViewController()
        navigationController?.pushViewController(cameraViewController, animated: true)
    }
    
}

extension HomeViewController: PageboyViewControllerDataSource {
    
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return viewControllers.count
    }
    
    func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
        return viewControllers[index]
    }
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return nil
    }
}

// MARK: - TMBarDataSource

extension HomeViewController: TMBarDataSource {
    
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        let title = index == 0 ? "지도뷰" : "날짜뷰"
        return TMBarItem(title: title)
    }
}

#Preview {
     HomeViewController()
}
