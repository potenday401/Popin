//
//  PDSNavigationBar+Preview.swift
//  Popin
//
//  Created by chamsol kim on 2/26/24.
//

import UIKit
import SnapKit

fileprivate final class PDSNavigationBarPreviewViewController: UIViewController {
    
    private lazy var bar1: PDSNavigationBar = {
        let bar = PDSNavigationBar()
        bar.title = "Text"
        bar.leftItem = .init(
            image: UIImage(systemName: "chevron.left"),
            target: self,
            action: #selector(buttonItemDidTap)
        )
        bar.rightItem = .init(
            image: UIImage(systemName: "plus"),
            target: self,
            action: #selector(buttonItemDidTap)
        )
        return bar
    }()
    
    private lazy var bar2: PDSNavigationBar = {
        let bar = PDSNavigationBar()
        bar.titleView = UIImageView(image: UIImage(resource: .logo))
        bar.leftItem = .init(
            image: UIImage(systemName: "chevron.left"),
            target: self,
            action: #selector(buttonItemDidTap)
        )
        bar.rightItem = .init(
            image: UIImage(systemName: "magnifyingglass"),
            target: self,
            action: #selector(buttonItemDidTap)
        )
        return bar
    }()
    
    private lazy var bar3: PDSNavigationBar = {
        let bar = PDSNavigationBar()
        bar.title = "Text"
        bar.leftItem = .init(
            image: UIImage(systemName: "chevron.left"),
            target: self,
            action: #selector(buttonItemDidTap)
        )
        bar.rightItem = .init(
            title: "저장",
            target: self,
            action: #selector(buttonItemDidTap)
        )
        return bar
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
        
        [bar1, bar2, bar3].forEach(stackView.addArrangedSubview(_:))
    }
    
    @objc
    private func buttonItemDidTap() {
        print(#function)
    }
}

#Preview {
    PDSNavigationBarPreviewViewController()
}
