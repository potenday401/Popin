//
//  AlbumInfoView.swift
//  Popin
//
//  Created by Jihaha kim on 2024/03/26.
//

import UIKit

class AlbumInfoView: UIView {
    var dateLabel: UILabel!
    var photoCountLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    private func setupViews() {
        let dateIconView: UIImageView = {
            let imageView = UIImageView(image: UIImage(named: "date"))
            imageView.contentMode = .scaleAspectFit
            return imageView
        }()
        
        let mapIconView: UIImageView = {
            let imageView = UIImageView(image: UIImage(systemName: "map"))
            imageView.tintColor = .white
            imageView.contentMode = .scaleAspectFit
            return imageView
        }()
        
        dateLabel = UILabel()
        dateLabel.text = "23.12.08"
        dateLabel.textColor = .white
        dateLabel.numberOfLines = 0
        
        photoCountLabel = UILabel()
        photoCountLabel.text = "56장의 기록 | 5곳의 장소"
        photoCountLabel.textColor = .white
        photoCountLabel.numberOfLines = 0
        
        addSubview(dateIconView)
        addSubview(dateLabel)
        addSubview(mapIconView)
        addSubview(photoCountLabel)
        
        dateIconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalTo(dateLabel)
            make.width.height.equalTo(20)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.leading.equalTo(dateIconView.snp.trailing).offset(8)
            make.top.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        mapIconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalTo(photoCountLabel)
            make.width.height.equalTo(20)
        }
        
        photoCountLabel.snp.makeConstraints { make in
            make.leading.equalTo(mapIconView.snp.trailing).offset(8)
            make.top.equalTo(dateLabel.snp.bottom).offset(8)
            make.trailing.equalToSuperview().offset(-16)
        }
        
    }
    func updateDate(_ date: String) {
        dateLabel.text = "Date: " + date
    }
    
    func updatePhotoCount(_ count: Int) {
        photoCountLabel.text = "Photos: \(count)"
    }
}
