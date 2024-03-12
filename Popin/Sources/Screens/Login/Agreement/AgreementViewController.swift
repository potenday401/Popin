//
//  AgreementViewController.swift
//  Popin
//
//  Created by chamsol kim on 3/11/24.
//

import UIKit
import SnapKit

final class AgreementViewController: LoginDetailBaseViewController {
    
    // MARK: - UI
    
    private let agreementItemListView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fillEqually
        stackView.spacing = 4
        return stackView
    }()
    
    private let agreeAllView = AgreeAllView()
    
    private let alertLabel: PDSAlertLabel = {
        let label = PDSAlertLabel()
        label.state = .error
        label.text = Text.errorAlertMessage
        label.isHidden = true
        return label
    }()
    
    private lazy var submitButton: PDSButton = {
        let button = PDSButton(style: .secondary, isFullWidth: false)
        button.setTitle("확인")
        button.addTarget(self, action: #selector(submitDidTap), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Setup
    
    override func setUpUI() {
        super.setUpUI()
        showsNavigationBar = false
        showsProgress = true
        
        contentView.addSubview(agreementItemListView)
        agreementItemListView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.leading.equalToSuperview().inset(8)
            make.trailing.equalToSuperview().inset(22)
        }
        
        Text.agreementItemTitles
            .map(AgreementItemView.init(title:))
            .forEach(agreementItemListView.addArrangedSubview(_:))
        
        contentView.addSubview(agreeAllView)
        agreeAllView.snp.makeConstraints { make in
            make.top.equalTo(agreementItemListView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
        }
        
        contentView.addSubview(alertLabel)
        alertLabel.snp.makeConstraints { make in
            make.top.equalTo(agreeAllView.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
        }
        
        contentView.addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(alertLabel.snp.bottom).offset(48)
            make.trailing.bottom.equalToSuperview()
        }
    }
}

// MARK: - Action

private extension AgreementViewController {
    
    @objc
    func submitDidTap() {
        // TODO: To Home?
    }
}

// MARK: - Constant

extension AgreementViewController {
    
    enum Text {
        static let agreementItemTitles = [
            "서비스 이용 약관 (필수)",
            "개인정보 수집 및 이용에 관한 동의 (필수)",
            "위치정보 (필수)",
            "카메라 앨범 (필수)"
        ]
        static let errorAlertMessage = "(필수) 약관에 동의해주세요."
    }
}
