//
//  PDSNavigationBarButtonItem.swift
//  Popin
//
//  Created by chamsol kim on 2/26/24.
//

import UIKit
import SnapKit

final class PDSNavigationBarButtonItem: UIView {
    
    // MARK: - UI
    
    private let stackView = UIStackView()
    
    // MARK: - Initializer
    
    convenience init(image: UIImage?, target: Any, action: Selector) {
        self.init(frame: .zero)
        
        let button = makeButton(with: target, action: action)
        button.setBackgroundImage(image, for: .normal)
        stackView.addArrangedSubview(button)
    }
    
    convenience init(title: String, target: Any, action: Selector) {
        self.init(frame: .zero)
        
        let button = makeButton(with: target, action: action)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        button.setTitle(title, for: .normal)
        stackView.addArrangedSubview(button)
    }
    
    private func makeButton(with target: Any, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.titleLabel?.textColor = .white
        button.addTarget(target, action: action, for: .touchUpInside)
        return button
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpUI() {
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - Intrinsic Content Size
    
    override var intrinsicContentSize: CGSize {
        if stackView.arrangedSubviews.first is UIImageView {
            return CGSize(width: 24, height: 24)
        }
        
        if let label = stackView.arrangedSubviews.first as? UILabel {
            return label.intrinsicContentSize
        }
        
        return super.intrinsicContentSize
    }
}
