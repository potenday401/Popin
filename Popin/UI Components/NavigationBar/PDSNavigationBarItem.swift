//
//  PDSNavigationBarItem.swift
//  Popin
//
//  Created by chamsol kim on 2/26/24.
//

import UIKit
import SnapKit

final class PDSNavigationBarItem: UIView {
    
    // MARK: - UI
    
    private let stackView = UIStackView()
    
    // MARK: - Initializer
    
    convenience init(image: UIImage?) {
        self.init(frame: .zero)
        
        let imageView = UIImageView(image: image)
        stackView.addArrangedSubview(imageView)
    }
    
    convenience init(title: String) {
        self.init(frame: .zero)
        
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 16, weight: .regular)
        titleLabel.text = title
        titleLabel.textColor = .white
        stackView.addArrangedSubview(titleLabel)
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
