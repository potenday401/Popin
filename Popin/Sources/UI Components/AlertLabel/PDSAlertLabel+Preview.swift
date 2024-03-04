//
//  PDSAlertLabel+Preview.swift
//  Popin
//
//  Created by chamsol kim on 3/4/24.
//

import UIKit
import SnapKit

fileprivate final class PDSAlertLabelPreviewViewController: UIViewController {
    
    private let normalAlertLabel: PDSAlertLabel = {
        let label = PDSAlertLabel()
        label.text = "입력 시간이 초과되었습니다."
        label.state = .normal
        return label
    }()
    private let errorAlertLabel: PDSAlertLabel = {
        let label = PDSAlertLabel()
        label.text = "유효하지 않은 이메일 주소입니다."
        label.state = .error
        return label
    }()
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 16
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        [normalAlertLabel, errorAlertLabel].forEach(stackView.addArrangedSubview(_:))
    }
}

#Preview {
    PDSAlertLabelPreviewViewController()
}
