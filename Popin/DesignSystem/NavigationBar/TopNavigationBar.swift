//
//  File.swift
//  Popin
//
//  Created by Jihaha kim on 2024/02/21.
//

import UIKit

protocol TopNavigationBarDelegate: AnyObject {
    func backButtonTapped()
}

class TopNavigationBar: UIView {
    weak var delegate: TopNavigationBarDelegate?

    // MARK: - Properties
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "back"), for: .normal)
        button.tintColor = .white
        button.addTarget(TopNavigationBar.self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let rightButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.tintColor = .white
        button.addTarget(TopNavigationBar.self, action: #selector(rightButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        backgroundColor = UIColor.grey700
        
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        addSubview(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        backButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        addSubview(rightButton)
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        rightButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        rightButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    // MARK: - Public Methods
    
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    func setRightButton(icon: UIImage?, action: @escaping () -> Void) {
        rightButton.setImage(icon, for: .normal)
        rightButton.addTarget(self, action: #selector(rightButtonTapped), for: .touchUpInside)
        rightButtonActionClosure = action
    }
    
    // MARK: - Actions
    
    @objc private func backButtonTapped() {
        delegate?.backButtonTapped()
    }
    
    @objc private func rightButtonTapped() {
        rightButtonActionClosure?()
    }
    private var rightButtonActionClosure: (() -> Void)?

}
