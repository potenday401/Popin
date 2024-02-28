//
//  File.swift
//  Popin
//
//  Created by 나리강 on 2/3/24.
//

import UIKit

class BaseViewController: UIViewController {
    
    // MARK: - Initialization
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray600
        setUpUI()
    }
    
    // MARK: - Setup
    
    func setUpUI() {
        
    }
}
