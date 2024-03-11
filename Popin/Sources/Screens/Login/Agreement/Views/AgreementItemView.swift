//
//  AgreementItemView.swift
//  Popin
//
//  Created by chamsol kim on 3/11/24.
//

import UIKit
import SnapKit

final class AgreementItemView: UIView {
    
    // MARK: - Interface
    
    var isChecked: Bool {
        get { checkbox.isSelected }
        set { checkbox.isSelected = newValue }
    }
    
    // MARK: - UI
    
    private let titleLabel: UILabel
    
    private let titleImageView: UIImageView = {
        let image = UIImage(resource: .agreementChevronRight)
        let imageView = UIImageView(image: image)
        return imageView
    }()
    
    private let checkbox = PDSCheckbox()
    
    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        return stackView
    }()
    
    private let titleContainer = UIView()
    
    // MARK: - Initializer
    
    init(title: String) {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.text = title
        label.textColor = .white
        titleLabel = label
        
        super.init(frame: .zero)
        setUpUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpUI() {
        addSubview(contentStackView)
        contentStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        [titleContainer, checkbox].forEach(contentStackView.addArrangedSubview(_:))
        
        titleContainer.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview().inset(8)
        }
        
        titleContainer.addSubview(titleImageView)
        titleImageView.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(8)
            make.trailing.lessThanOrEqualToSuperview().inset(8)
            make.centerY.equalToSuperview()
            make.size.equalTo(12)
        }
    }
    
    // MARK: - Intrinsic Content Size
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: CGFloat.greatestFiniteMagnitude, height: 44)
    }
}
