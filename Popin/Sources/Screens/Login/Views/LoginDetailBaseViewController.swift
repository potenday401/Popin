//
//  LoginDetailBaseViewController.swift
//  Popin
//
//  Created by chamsol kim on 3/6/24.
//

import UIKit
import SnapKit

class LoginDetailBaseViewController: BaseViewController {
    
    // MARK: - Interface
    
    var showsProgress = false {
        didSet {
            progressView.isHidden = !showsProgress
        }
    }
    
    let contentView = UIView()
    
    // MARK: - UI
    
    private lazy var _navigationBar: PDSNavigationBar = {
        let navigationBar = PDSNavigationBar()
        navigationBar.titleView = UIImageView(image: UIImage(resource: .logo))
        return navigationBar
    }()
    
    private let progressView: SignUpProgressView = {
        let progressView = SignUpProgressView(step: 4)
        progressView.isHidden = true
        return progressView
    }()
    
    private let titleLabel: UILabel
    
    // MARK: - Initializer
    
    init(title: String) {
        let label = UILabel()
        label.text = title
        label.textColor = .white
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        titleLabel = label
        
        super.init()
    }
    
    // MARK: - Setup
    
    override func setUpUI() {
        shouldEndEditingIfTouchesEnded = true
        
        let inset: CGFloat = 16
        
        view.addSubview(_navigationBar)
        _navigationBar.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        
        view.addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.top.equalTo(_navigationBar.snp.bottom).offset(30)
            make.leading.equalTo(view.safeAreaLayoutGuide).inset(34)
        }
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(progressView.snp.bottom).offset(35)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(inset)
        }
        
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(25)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(inset)
        }
    }
}