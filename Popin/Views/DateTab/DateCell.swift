//
//  File.swift
//  Popin
//
//  Created by 나리강 on 2/3/24.
//

import UIKit
import FSCalendar
import SnapKit
import Kingfisher

class DateCell: FSCalendarCell {
    
    var viewModel: DateViewModel? {
        didSet {
            viewModel?.updateDateImage(image: backImageView)
        }
    }
    
    var backImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "Logo")
        view.alpha = 0.5
        
        //임의의 이미지, 나중에 삭제
        
        let imageUrl = URL(string: "https://placekitten.com/100/100?image=1")!
        view.kf.setImage(with: imageUrl)
        
        //view.layer.borderColor = UIColor.white.cgColor
        //view.layer.borderWidth = 5
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
        constraints()
        
        //통신되면 지우기
        viewModel?.updateDateImage(image: backImageView)
    }
    
    required init(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        //backImageView.image = nil
    }
    
    func configure() {
        contentView.insertSubview(backImageView, at: 0)
    }
    
    func constraints() {
        
        backImageView.snp.makeConstraints { make in
            make.center.equalTo(contentView)
            make.size.equalTo(minSize())
        }
        
        backImageView.layer.cornerRadius = minSize()/2
        
        self.titleLabel.snp.makeConstraints { make in
            make.center.equalTo(contentView)
        }
    }
    
    // 셀의 높이와 너비 중 작은 값을 리턴한다
    func minSize() -> CGFloat {
        let width = contentView.bounds.width - 5
        let height = contentView.bounds.height - 5
        
        return (width > height) ? height : width
    }
}

