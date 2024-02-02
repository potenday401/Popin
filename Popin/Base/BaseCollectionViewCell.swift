//
//  BaseCollectionViewCell.swift
//  Popin
//
//  Created by 나리강 on 2/2/24.
//

import UIKit

class BaseCollectionViewCell: UICollectionViewCell {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
        constraints()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {}
    func constraints() {}
}
