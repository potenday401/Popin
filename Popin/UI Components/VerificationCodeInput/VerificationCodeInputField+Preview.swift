//
//  VerificationCodeInputField+Preview.swift
//  Popin
//
//  Created by chamsol kim on 2/26/24.
//

import UIKit
import SnapKit

fileprivate final class VerificationCodeInputFieldPreviewViewController: UIViewController {
    
    private let inputField = VerificationCodeInputField(numberOfDigits: 5)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .gray700
        
        view.addSubview(inputField)
        inputField.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}


#Preview {
    VerificationCodeInputFieldPreviewViewController()
}
