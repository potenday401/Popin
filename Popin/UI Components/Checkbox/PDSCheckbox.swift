//
//  PDSCheckbox.swift
//  Popin
//
//  Created by chamsol kim on 2/26/24.
//

import UIKit
import SnapKit

final class PDSCheckbox: UIView {
    
    // MARK: - Interface
    
    var isSelected: Bool {
        get { button.isSelected }
        set { button.isSelected = newValue }
    }
    
    // MARK: - UI
    
    private lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .clear
        button.setBackgroundImage(UIImage(resource: .checkmarkOff), for: .normal)
        button.setBackgroundImage(UIImage(resource: .checkmarkOn), for: .selected)
        button.addTarget(self, action: #selector(buttonDidTap), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpUI() {
        addSubview(button)
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }    }
    
    // MARK: - Intrinsic Content Size
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: 24, height: 24)
    }
}

private extension PDSCheckbox {
    
    @objc
    func buttonDidTap(_ sender: UIButton) {
        sender.isSelected.toggle()
    }
}
