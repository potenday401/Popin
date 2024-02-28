//
//  PDSNavigationBar+Preview.swift
//  Popin
//
//  Created by chamsol kim on 2/26/24.
//

import UIKit
import SnapKit

fileprivate final class PDSNavigationBarPreviewViewController: UIViewController {
    
    private let bar1: PDSNavigationBar = {
        let bar = PDSNavigationBar()
        bar.title = "Text"
        bar.leftItem = .init(image: UIImage(systemName: "chevron.left"))
        bar.rightItem = .init(image: UIImage(systemName: "plus"))
        return bar
    }()
    
    private let bar2: PDSNavigationBar = {
        let bar = PDSNavigationBar()
        bar.titleView = UIImageView(image: UIImage(resource: .logo))
        bar.leftItem = .init(image: UIImage(systemName: "chevron.left"))
        bar.rightItem = .init(image: UIImage(systemName: "magnifyingglass"))
        return bar
    }()
    
    private let bar3: PDSNavigationBar = {
        let bar = PDSNavigationBar()
        bar.title = "Text"
        bar.leftItem = .init(image: UIImage(systemName: "chevron.left"))
        bar.rightItem = .init(title: "저장")
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
}

#Preview {
    PDSNavigationBarPreviewViewController()
}
