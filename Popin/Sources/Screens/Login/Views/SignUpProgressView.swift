//
//  SignUpProgressView.swift
//  Popin
//
//  Created by chamsol kim on 3/6/24.
//

import UIKit
import SnapKit

final class SignUpProgressView: UIView {
    
    // MARK: - UI
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .signupPin)
        return imageView
    }()
    private let trackView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray400
        view.layer.cornerRadius = Metric.trackWidth / 2
        return view
    }()
    private let progressView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Metric.trackWidth / 2
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = Color.gradientColors
        gradientLayer.startPoint = .init(x: 0, y: 0.5)
        gradientLayer.endPoint = .init(x: 1, y: 0.5)
        return gradientLayer
    }()
    
    // MARK: - Property
    
    private let step: CGFloat
    private var progress: CGFloat
    
    // MARK: - Initializer
    
    init(step: Int, initial: Int = 1) {
        self.step = CGFloat(step)
        progress = CGFloat(min(initial, step)) / self.step
        super.init(frame: .zero)
        setUpUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpUI() {
        addSubview(trackView)
        trackView.snp.makeConstraints { make in
            make.leading.bottom.equalToSuperview()
            make.trailing.bottom.equalToSuperview()
            make.width.equalTo(78)
            make.height.equalTo(Metric.trackWidth)
        }
        
        addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.top.leading.bottom.equalTo(trackView)
            make.width.equalTo(trackView).multipliedBy(progress)
        }
        
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalTo(progressView.snp.top).offset(-5)
            make.centerX.equalTo(progressView.snp.trailing).offset(-Metric.trackWidth / 2)
        }
        
        progressView.layer.addSublayer(gradientLayer)
    }
    
    // MARK: - Layout Subviews
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if gradientLayer.superlayer == nil {
            progressView.layer.addSublayer(gradientLayer)
        }
        gradientLayer.frame = trackView.bounds
    }
    
    // MARK: - Intrinsic Content Size
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: 84, height: 40)
    }
}

// MARK: - Constant

private extension SignUpProgressView {
    
    enum Metric {
        static let trackWidth: CGFloat = 8
    }
    
    enum Color {
        static let gradientColors = [
            UIColor(hex: 0xA468F8).cgColor,
            UIColor(hex: 0xCE85C3).cgColor,
            UIColor(hex: 0xEAD46A).cgColor
        ]
    }
}
