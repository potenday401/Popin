//
//  PDSCarouselItem.swift
//  Popin
//
//  Created by chamsol kim on 3/29/24.
//

import UIKit
import ScalingCarousel
import SnapKit

class PDSCarouselItem: ScalingCarouselCell {
    
    // MARK: - Interface
    
    func addContentView(_ contentView: UIView) {
        mainView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        cornerRadius = 0
        setUpMainView()
    }
    
    private func setUpMainView() {
        mainView = UIView(frame: contentView.bounds)
        contentView.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        mainView.subviews.forEach { $0.removeFromSuperview() }
    }
}
