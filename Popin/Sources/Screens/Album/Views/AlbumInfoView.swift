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
    var pinCount: Int!
    
    init(pinCount: Int) {
        super.init(frame: .zero)
        self.pinCount = pinCount
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    private func currentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy.MM.dd"
        return dateFormatter.string(from: Date())
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
        dateLabel.text = currentDate()
        dateLabel.textColor = .white
        dateLabel.numberOfLines = 0
        
        photoCountLabel = UILabel()
        updatePhotoCountText()
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
            make.trailing.equalToSuperview().offset(-1)
        }
        
        mapIconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalTo(photoCountLabel)
            make.width.height.equalTo(20)
        }
        
        photoCountLabel.snp.makeConstraints { make in
            make.leading.equalTo(mapIconView.snp.trailing).offset(8)
            make.top.equalTo(dateLabel.snp.bottom).offset(8)
            make.trailing.equalToSuperview().offset(-1)
        }
    }
    
    func updateDate(_ date: String) {
        dateLabel.text = "Date: " + date
    }
    
    func updatePhotoCountText() {
        if let pinCount = pinCount {
            photoCountLabel.text = "\(pinCount)장의 기록 | \(pinCount)곳의 장소"
        } else {
            photoCountLabel.text = "장의 기록 | 곳의 장소"
        }
    }
    
    func updatePhotoCount(_ count: Int) {
        self.pinCount = count
        updatePhotoCountText()
    }
}
