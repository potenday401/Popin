//
//  LogInView.swift
//  Popin
//
//  Created by 나리강 on 2/4/24.
//


import UIKit
import SnapKit

final class LogInView: BaseView {

    let logoImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "Icon")
        return view
    }()
    let textFieldStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 16
        view.distribution = .fillEqually
        return view
    }()

    let labelStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 24
        view.distribution = .fillEqually

        return view
    }()

    let idTextField: UITextField = {
        let view = UITextField()
        //view.placeholder = "사용자 이메일"
        view.layer.cornerRadius = 12
        view.textColor = .white
        view.font = variousFont.textFieldFont
        view.backgroundColor = Color.shared.textFieldColor
        view.attributedPlaceholder = NSAttributedString(string: "사용자 이메일", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        view.keyboardType = .emailAddress
        return view
    }()
    let pwTextField: UITextField = {
        let view = UITextField()
        //view.placeholder = "비밀번호"
        view.layer.cornerRadius = 12
        view.textColor = .white
        view.font = variousFont.textFieldFont
        view.backgroundColor = Color.shared.textFieldColor
        view.attributedPlaceholder = NSAttributedString(string: "비밀번호", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        view.keyboardType = .asciiCapable
        return view
    }()
    let loginButton: UIButton = {
        let view = UIButton()
        view.setTitle("로그인하기", for: .normal)
        view.layer.cornerRadius = 8
        view.titleLabel?.font = variousFont.buttonFont
        view.backgroundColor = Color.shared.buttonColor
        return view
    }()

    let changePwLabel: UILabel = {
        let view = UILabel()
        view.text = "비밀번호 찾기"
        view.textAlignment = .right
        view.textColor = .white
        view.font = variousFont.labelFont
        return view
    }()
    let signUpLabel: UILabel = {
        let view = UILabel()
        view.text = "회원가입하기"
        view.textAlignment = .left
        view.textColor = .white
        view.font = variousFont.labelFont
        return view
    }()

    override func configure() {
        [logoImage, textFieldStackView, loginButton, labelStackView].forEach {
            self.addSubview($0)
        }
        [idTextField, pwTextField].forEach {
            textFieldStackView.addArrangedSubview($0)
        }
        [changePwLabel, signUpLabel].forEach {
            labelStackView.addArrangedSubview($0)
        }
    }

    override func constraints() {
        logoImage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.5)
            make.width.equalToSuperview().multipliedBy(0.2)
            make.height.equalTo(logoImage.snp.width)
        }

        textFieldStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.9)
            make.leading.trailing.equalToSuperview().inset(12)
            make.height.equalTo(144)
        }

        loginButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(textFieldStackView.snp.bottom).offset(80)
            make.height.equalTo(56)
            make.leading.trailing.equalToSuperview().inset(12)
        }

        labelStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(12)
            make.top.equalTo(loginButton.snp.bottom).offset(24)
        }

        changePwLabel.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
        }

        signUpLabel.snp.makeConstraints { make in
            make.trailing.top.bottom.equalToSuperview()
        }
    }

}
