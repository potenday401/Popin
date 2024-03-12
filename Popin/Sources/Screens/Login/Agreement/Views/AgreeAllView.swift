//
//  AgreeAllView.swift
//  Popin
//
//  Created by chamsol kim on 3/11/24.
//

import UIKit
import SnapKit

final class AgreeAllView: UIView {
    
    // MARK: - Interface
    
    var isChecked: Bool {
        get { checkbox.isSelected }
        set { checkbox.isSelected = newValue }
    }
    
    // MARK: - UI
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "모든 약관 동의"
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    private let checkbox = PDSCheckbox()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpUI() {
        layer.borderWidth = 1
        layer.borderColor = UIColor.gray300.cgColor
        layer.cornerRadius = 8
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(19)
            make.centerY.equalToSuperview()
        }
        
        addSubview(checkbox)
        checkbox.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(19)
            make.centerY.equalToSuperview()
        }
    }
    
    // MARK: - Intrinsic Content Size
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: CGFloat.greatestFiniteMagnitude, height: 66)
    }
}
