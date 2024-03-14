//
//  ProfileViewController.swift
//  Popin
//
//  Created by Jihaha kim on 2024/03/13.
//

import UIKit

final class ProfileViewController: BaseViewController {
    
    var router: ProfileRouter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let profileRouter = ProfileRouterImp()
        profileRouter.viewController = self
        router = profileRouter
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupUI()
    }
    
    private lazy var myLoginInfo: UILabel = {
        let label = UILabel()
        let text = "사용자 이메일\nabcd@abcd.com"
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = 16
        paragraphStyle.lineSpacing = 8
        let attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedText.length))
        
        label.attributedText = attributedText
        
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .gray200
        label.numberOfLines = 2
        label.textAlignment = .left
        label.backgroundColor = .gray500
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        return label
    }()

    
    private lazy var changePasswordButton: UIButton = {
        let button = makeButton(title: "비밀번호 수정", backgroundColor: .gray500, titleColor: .white)
        button.addTarget(self, action: #selector(changePasswordDidTap), for: .touchUpInside)
        return button
    }()

    private lazy var logoutButton: UIButton = {
        let button = makeButton(title: "로그아웃", backgroundColor: .gray500, titleColor: .white)
        button.addTarget(self, action: #selector(logoutDidTap), for: .touchUpInside)
        return button
    }()

    private lazy var withdrawButton: UIButton = {
        let button = makeButton(title: "탈퇴하기", backgroundColor: .black, titleColor: .red)
        button.addTarget(self, action: #selector(withdrawDidTap), for: .touchUpInside)
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
    

    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        return stackView
    }()
    @objc
    func changePasswordDidTap() {
        
    }

    @objc
    func logoutDidTap() {
        
    }

    @objc
    func withdrawDidTap() {
        
    }

    // animation 효과때문에 단순 back으로 하는게 좋을지?
    @objc
    func backDidTap() {
        router?.routeToHome()
    }
    
    private let navigationBar: PDSNavigationBar = {
        let navigationBar = PDSNavigationBar()
        navigationBar.title = "마이페이지"
        return navigationBar
    }()
    
    private func setupUI() {
        view.addSubview(navigationBar)
        navigationBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
        }
        
        view.addSubview(myLoginInfo)
        myLoginInfo.snp.makeConstraints { make in
             make.top.equalTo(navigationBar.snp.bottom).offset(16)
             make.leading.trailing.equalToSuperview().inset(16)
             make.height.equalTo(62)
             make.width.equalTo(343)
         }
        
        view.addSubview(buttonStackView)
        buttonStackView.snp.makeConstraints { make in
            make.top.equalTo(myLoginInfo.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        changePasswordButton.snp.makeConstraints { make in
               make.height.equalTo(56)
               make.width.equalTo(343)
           }

           logoutButton.snp.makeConstraints { make in
               make.height.equalTo(56)
               make.width.equalTo(343)
           }

           withdrawButton.snp.makeConstraints { make in
               make.height.equalTo(56)
               make.width.equalTo(343)
           }

        buttonStackView.axis = .vertical

        [changePasswordButton, logoutButton, withdrawButton].forEach(buttonStackView.addArrangedSubview(_:))
        
        navigationBar.leftItem = .init(
            image: UIImage(resource: .chevronLeft),
            target: self,
            action: #selector(backDidTap)
        )
    }

}

//#Preview {
//    ProfileViewController()
//}
