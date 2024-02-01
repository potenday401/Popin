//
//  BaseView.swift
//  Popin
//
//  Created by 나리강 on 2/1/24.
//

import UIKit

class BaseView: UIView {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
        constraints()
    
        backgroundColor = .black
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {}
    func constraints() {}
}
