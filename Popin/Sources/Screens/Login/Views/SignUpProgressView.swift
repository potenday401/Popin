//
//  SignUpProgressView.swift
//  Popin
//
//  Created by chamsol kim on 3/6/24.
//

import UIKit
import SnapKit

final class SignUpProgressView: UIView {
    
    // MARK: - Interface
    
    var step: Int {
        get { currentStep }
        set { currentStep = newValue }
    }
    
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
    
    private let numberOfStep: Int
    private var currentStep: Int {
        didSet {
            progress = CGFloat(min(step, numberOfStep)) / CGFloat(numberOfStep)
        }
    }
    private var progress: CGFloat {
        didSet {
            makeProgressConstraints()
        }
    }
    
    private var progressConstraint: Constraint?
    private var isConstraintUpdated = false
    
    // MARK: - Initializer
    
    init(numberOfStep: Int, initial: Int = 1) {
        self.numberOfStep = max(0, numberOfStep)
        currentStep = initial
        progress = CGFloat(max(0, min(initial, currentStep))) / CGFloat(self.numberOfStep)
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
        makeProgressConstraints()
        
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalTo(progressView.snp.top).offset(-5)
            make.centerX.equalTo(progressView.snp.trailing).offset(-Metric.trackWidth / 2)
        }
        
        progressView.layer.addSublayer(gradientLayer)
    }
    
    private func makeProgressConstraints() {
        progressView.snp.remakeConstraints { make in
            make.top.leading.bottom.equalTo(trackView)
            make.width.equalTo(trackView).multipliedBy(progress)
        }
    }
    
    // MARK: - Lifecycle
    
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

#if DEBUG

fileprivate class SignUpProgressViewPreviewViewController: UIViewController {
    
    let progressViewProgress1 = SignUpProgressView(numberOfStep: 4, initial: 1)
    let progressViewProgressStep2 = SignUpProgressView(numberOfStep: 4, initial: 2)
    let progressViewProgressStep3 = SignUpProgressView(numberOfStep: 4, initial: 3)
    let progressViewProgressStep4 = SignUpProgressView(numberOfStep: 4, initial: 4)
    
    let progressViewProgressDynamic = SignUpProgressView(numberOfStep: 4)
    let stepper = UIStepper()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stepper.minimumValue = 1
        stepper.maximumValue = 4
        stepper.stepValue = 1
        stepper.addTarget(self, action: #selector(stepperValueChanged), for: .valueChanged)
        
        view.backgroundColor = .gray600
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        [
            progressViewProgress1,
            progressViewProgressStep2,
            progressViewProgressStep3,
            progressViewProgressStep4,
            progressViewProgressDynamic,
            stepper
        ].forEach(stackView.addArrangedSubview(_:))
    }
    
    @objc
    func stepperValueChanged(_ stepper: UIStepper) {
        progressViewProgressDynamic.step = Int(stepper.value)
    }
}

#Preview {
    SignUpProgressViewPreviewViewController()
}

#endif
