//
//  PDSVerificationCodeDigit.swift
//  Popin
//
//  Created by chamsol kim on 2/26/24.
//

import UIKit
import SnapKit

class PDSVerificationCodeDigit: UIView {
    
    // MARK: - Interface
    
    var isFailure = false {
        didSet {
            label.textColor = isFailure ? .pink100 : .white
        }
    }
    
    func setNumber(_ number: String) {
        let isNumber = number.allSatisfy { $0.isNumber }
        label.text = isNumber ? number : nil
        dot.isHidden = isNumber
    }
    
    // MARK: - UI
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 30, weight: .semibold)
        return label
    }()
    
    private let dot: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .darkGray200
        view.layer.cornerRadius = Metric.dotSize.width / 2
        return view
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
        [dot, label].forEach(addSubview(_:))
        
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        dot.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(Metric.dotSize)
        }
    }
    
    // MARK: - Intrinsic Content Size
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: 36, height: 51)
    }
}

private extension PDSVerificationCodeDigit {
    
    enum Metric {
        static let dotSize = CGSize(width: 12, height: 12)
    }
}
