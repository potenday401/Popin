//
//  PDSCheckbox+Preview.swift
//  Popin
//
//  Created by chamsol kim on 2/26/24.
//

import UIKit
import SnapKit

fileprivate final class PDSCheckboxPreviewViewController: UIViewController {
    
    private let normalCheckbox = PDSCheckbox()
    private let selectedCheckbox: PDSCheckbox = {
        let checkbox = PDSCheckbox()
        checkbox.isSelected = true
        return checkbox
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        stackView.layer.cornerRadius = 8
        stackView.backgroundColor = .lightGray
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        [normalCheckbox, selectedCheckbox].forEach(stackView.addArrangedSubview(_:))
    }
}

#Preview {
    PDSCheckboxPreviewViewController() 
}
