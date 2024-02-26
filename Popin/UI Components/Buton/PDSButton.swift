//
//  PDSButton.swift
//  Popin
//
//  Created by chamsol kim on 2/23/24.
//

import UIKit
import SnapKit

final class PDSButton: UIButton {
    
    // MARK: - Interface
    
    func setImage(_ image: UIImage?) {
        _imageView.image = image
        
        guard !stackView.arrangedSubviews.contains(_imageView) else {
            return
        }
        
        stackView.insertArrangedSubview(_imageView, at: 0)
    }
    
    func setTitle(_ title: String) {
        _titleLabel.text = title
    }
    
    // MARK: - UI
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        return stackView
    }()
    
    private let _imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .white
        imageView.snp.makeConstraints { make in
            make.size.equalTo(24)
        }
        return imageView
    }()
    
    private let _titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    // MARK: - Property
    
    private let style: Style
    
    // MARK: - Initialization
    
    init(style: Style) {
        self.style = style
        super.init(frame: .zero)
        setUpUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setUpUI() {
        clipsToBounds = true
        layer.cornerRadius = 8
        Self.colors[style]?.forEach {
            setBackgroundImage(UIImage(color: $0.value), for: $0.state)
        }
        
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        stackView.addArrangedSubview(_titleLabel)
    }
}

// MARK: - Style

extension PDSButton {
    
    enum Style {
        case primary
        case secondary
    }
}

// MARK: - Color

fileprivate extension PDSButton {
    
    struct Color {
        let value: UIColor
        let state: UIControl.State
    }
    
    static let colors: [Style: [Color]] = [
        .primary: [
            Color(value: .indigo200, state: .normal),
            Color(value: .indigo300, state: .highlighted),
            Color(value: .darkGray500, state: .disabled),
        ],
        .secondary: [
            Color(value: .darkGray300, state: .normal),
            Color(value: .darkGray500, state: .highlighted),
            Color(value: .darkGray400, state: .disabled),
        ],
    ]
}
