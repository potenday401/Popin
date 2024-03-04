//
//  PDSAlertLabel.swift
//  Popin
//
//  Created by chamsol kim on 3/4/24.
//

import UIKit
import SnapKit

final class PDSAlertLabel: UIView {
    
    // MARK: - Interface
    
    var text: String? {
        get { label.text }
        set { label.text = newValue }
    }
    
    var state: State = .normal {
        didSet {
            imageView.image = Image.alert(with: state.tintColor)
            label.textColor = state.textColor
        }
    }
    
    // MARK: - UI
    
    private let imageView: UIImageView = {
        let image = Image.alert(with: State.normal.tintColor)
        let imageView = UIImageView(image: image)
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = State.normal.textColor
        return label
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        return stackView
    }()
    
    // MARK: - Initializer
    
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
        
        [imageView, label].forEach(stackView.addArrangedSubview(_:))
        imageView.snp.makeConstraints { make in
            make.size.equalTo(24)
        }
    }
}

// MARK: - State

extension PDSAlertLabel {
    
    enum State {
        case normal
        case error
        
        var tintColor: UIColor {
            switch self {
            case .normal:   .gray200
            case .error:    .pink200
            }
        }
        
        var textColor: UIColor {
            switch self {
            case .normal:   .gray100
            case .error:    .pink200
            }
        }
    }
}

// MARK: - Constant

extension PDSAlertLabel {
    
    enum Image {
        static func alert(with color: UIColor) -> UIImage {
            UIImage(resource: .alert).withTintColor(color)
        }
    }
}
