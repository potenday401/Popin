//
//  HomeViewController.swift
//  fourpin
//
//  Created by Jihaha kim on 2024/01/30.
//

import UIKit
import Tabman
import Pageboy

class HomeViewController: TabmanViewController {
    
    private var viewControllers: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewModel = DateViewModel()
        let dateViewController = DateViewController(viewModel: viewModel)
        let homeMapViewController = HomeMapViewController()
        
        viewControllers.append(homeMapViewController)
        viewControllers.append(dateViewController)
        
        let bar = TMBar.ButtonBar()
        addBar(bar, dataSource: self, at: .top)
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
