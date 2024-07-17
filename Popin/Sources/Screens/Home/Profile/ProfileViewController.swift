//
//  ProfileViewController.swift
//  Popin
//
//  Created by Jihaha kim on 2024/03/13.
//

import UIKit

protocol ProfileViewControllerDelegate: AnyObject {
    func requestProfileViewControllerBackDidTap(_ viewController: ProfileViewController)
}

final class ProfileViewController: BaseViewController {
    weak var delegate: ProfileViewControllerDelegate?
    var router: HomeRouter?
    var accessToken: String?
    var refreshToken: String?
    var appRouter: AppRouter?
    var dependency: Dependency? {
        didSet {
            initializeDependencyIfNeeded()
        }
    }
    weak var window: UIWindow?
    private var isLogoutRequestInProgress = false

    override func viewDidLoad() {
        print(TokenManager.shared.accessToken, TokenManager.shared.refreshToken, "tokens check")
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupUI()
        initializeDependencyIfNeeded()
    }
    
    private lazy var myLoginInfo: UILabel = {
        let label = UILabel()
        let email = TokenManager.shared.getEmail() ?? ""
        let text = "\(email)"
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
    
    private func makeButton(title: String, backgroundColor: UIColor, titleColor: UIColor) -> UIButton {
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
        // Handle change password action
    }
    
    @objc func logoutDidTap(_ sender: UIButton) {
        guard !isLogoutRequestInProgress else { return }
        isLogoutRequestInProgress = true

        guard let accessToken = TokenManager.shared.accessToken else {
            print("No access token available")
            isLogoutRequestInProgress = false
            return
        }

        var request = URLRequest(url: Endpoint.Member.logout.url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            self.isLogoutRequestInProgress = false
            
            if let error = error {
                DispatchQueue.main.async {
                    self.showAlert(message: "Logout failed: \(error.localizedDescription)")
                }
                print("Error: \(error)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    self.showAlert(message: "Logout failed: Invalid response")
                }
                return
            }

            if httpResponse.statusCode == 200 {
                TokenManager.shared.clearTokens()
                DispatchQueue.main.async {
                    self.handleLogoutSuccess()
                }
            } 
            else {
                DispatchQueue.main.async {
                    self.showAlert(message: "Logout failed with status code \(httpResponse.statusCode)")
                }
                print("Logout failed with status code \(httpResponse.statusCode)")
            }
        }
        task.resume()
    }
    
    private func handleUnauthorized() {
        DispatchQueue.main.async {
            self.showAlert(message: "Session expired. Please log in again.")
            self.handleLogoutSuccess()
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func handleLogoutSuccess() {
        guard let dependency = self.dependency else {
            print("Dependency is not set")
            return
        }
        
        let loginService = LoginServiceImp(
            network: dependency.network,
            validator: dependency.validator
        )
        
        let loginDependency = LoginViewController.Dependency(
            loginService: loginService,
            tokenRepository: dependency.tokenRepository
        )
        
        let loginRouter = LoginRouterImp(
            dependency: .init(
                network: dependency.network,
                validator: dependency.validator
            )
        )
        
        loginRouter.window = window
        
        let loginViewController = LoginViewController(dependency: loginDependency)
        loginViewController.router = loginRouter
        loginRouter.viewController = loginViewController
        
        DispatchQueue.main.async {
            if let window = UIApplication.shared.windows.first {
                window.rootViewController = loginViewController
                UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil, completion: nil)
            } else {
                print("UIApplication.shared.windows.first is nil")
            }
        }
    }
    
    private func handleWithdrawSuccess() {
        guard let dependency = self.dependency else {
            print("Dependency is not set")
            return
        }
        
        let loginService = LoginServiceImp(
            network: dependency.network,
            validator: dependency.validator
        )
        
        let loginDependency = LoginViewController.Dependency(
            loginService: loginService,
            tokenRepository: dependency.tokenRepository
        )
        
        let loginRouter = LoginRouterImp(
            dependency: .init(
                network: dependency.network,
                validator: dependency.validator
            )
        )
        
        loginRouter.window = window
        
        let loginViewController = LoginViewController(dependency: loginDependency)
        loginViewController.router = loginRouter
        loginRouter.viewController = loginViewController
        
        DispatchQueue.main.async {
            if let window = UIApplication.shared.windows.first {
                window.rootViewController = loginViewController
                UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil, completion: nil)
            } else {
                print("UIApplication.shared.windows.first is nil")
            }
        }
    }
    @objc func withdrawDidTap() {
        guard let accessToken = TokenManager.shared.accessToken, let refreshToken = TokenManager.shared.refreshToken else {
            print("No access token or refresh token available")
            return
        }
        
        var request = URLRequest(url: Endpoint.Member.withdrawal.url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue(refreshToken, forHTTPHeaderField: "RefreshToken")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    DispatchQueue.main.async {
                        self.handleWithdrawSuccess()
                    }
                } else {
                    print("Withdraw failed with status code \(httpResponse.statusCode)")
                }
            }
        }
        task.resume()
    }
    
    @objc
    func backDidTap() {
        delegate?.requestProfileViewControllerBackDidTap(self)
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
    
    private func initializeDependencyIfNeeded() {
        guard dependency == nil else { return }
        var sessionConfiguration: URLSessionConfiguration {
            let configuration = URLSessionConfiguration.default
            return configuration
        }
        let network = AlamofireNetwork(configuration: sessionConfiguration)
        let tokenStorage = TokenKeychainStorage()
        let tokenRepository = TokenRepositoryImp(storage: tokenStorage)
        let validator = EmailPasswordValidator()
        dependency = Dependency(network: network, tokenRepository: tokenRepository, validator: validator)
    }
}

struct Dependency {
    let network: Network
    let tokenRepository: TokenRepository
    let validator: EmailPasswordValidatorType
}
