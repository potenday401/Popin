//
//  PDSNavigationBar.swift
//  Popin
//
//  Created by chamsol kim on 2/26/24.
//

import UIKit
import SnapKit

final class PDSNavigationBar: UIView {
    
    // MARK: - Interface
    
    var title: String? {
        get { (titleView as? UILabel)?.text }
        set {
            titleView = nil
            
            guard let title = newValue else {
                return
            }
            
            let label = UILabel()
            label.font = .systemFont(ofSize: 16, weight: .bold)
            label.text = title
            label.textColor = .white
            titleView = label
        }
    }
    
    var titleView: UIView? {
        didSet {
            titleStackView.removeAllArrangedSubviews()
            
            guard let titleView else {
                return
            }
            
            titleStackView.addArrangedSubview(titleView)
        }
    }
    
    var leftItem: PDSNavigationBarButtonItem? {
        didSet {
            leftStackView.removeAllArrangedSubviews()
            
            guard let leftItem else {
                return
            }
            
            leftStackView.addArrangedSubview(leftItem)
        }
    }
    
    var rightItem: PDSNavigationBarButtonItem? {
        didSet {
            rightStackView.removeAllArrangedSubviews()
            
            guard let rightItem else {
                return
            }
            
            rightStackView.addArrangedSubview(rightItem)
        }
    }
    
    // MARK: - UI
    
    private let titleStackView = UIStackView()
    private let leftStackView = UIStackView()
    private let rightStackView = UIStackView()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpUI() {
        backgroundColor = .gray600
        
        [leftStackView, titleStackView, rightStackView].forEach(addSubview(_:))
        leftStackView.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview().inset(Metric.inset)
        }
        titleStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        rightStackView.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview().inset(Metric.inset)
        }
    }
    
    // MARK: - Intrinsic Content Size
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: 0, height: 50)
    }
}

// MARK: - Constant

private extension PDSNavigationBar {
    
    enum Metric {
        static let inset = UIEdgeInsets(top: 13, left: 13, bottom: 13, right: 13)
    }
}
