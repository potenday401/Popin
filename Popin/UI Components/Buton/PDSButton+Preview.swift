//
//  PDSButton+Preview.swift
//  Popin
//
//  Created by chamsol kim on 2/23/24.
//

import UIKit
import SnapKit

fileprivate final class PDSButtonPreviewViewController: UIViewController {
    
    let primaryButton: PDSButton = {
        let button = PDSButton(style: .primary)
        button.setTitle("Primary")
        return button
    }()
    let primaryButtonWithImage: PDSButton = {
        let button = PDSButton(style: .primary)
        button.setImage(UIImage(systemName: "paperplane"))
        button.setTitle("Primary")
        return button
    }()
    let primaryDisabledButton: PDSButton = {
        let button = PDSButton(style: .primary)
        button.setTitle("Primary Disabled")
        button.isEnabled = false
        return button
    }()
    let secondaryButton: PDSButton = {
        let button = PDSButton(style: .secondary)
        button.setTitle("Secondary")
        return button
    }()
    let secondaryButtonWithImage: PDSButton = {
        let button = PDSButton(style: .secondary)
        button.setImage(UIImage(systemName: "paperplane"))
        button.setTitle("Secondary")
        return button
    }()
    let secondaryDisabledButton: PDSButton = {
        let button = PDSButton(style: .secondary)
        button.setTitle("Secondary Disabled")
        button.isEnabled = false
        return button
    }()
    var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        let buttons = [
            primaryButton,
            primaryButtonWithImage,
            primaryDisabledButton,
            secondaryButton,
            secondaryButtonWithImage,
            secondaryDisabledButton
        ]
        buttons.forEach(stackView.addArrangedSubview(_:))
        buttons.forEach {
            $0.snp.makeConstraints { make in
                make.size.equalTo(CGSize(width: 300, height: 56))
            }
        }
    }
}

#Preview {
    UINavigationController(rootViewController: PDSButtonPreviewViewController())
}
