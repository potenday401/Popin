//
//  ImageCacheManager.swift
//  fourpin
//
//  Created by Jihaha kim on 2024/01/30.
//

import UIKit
import Kingfisher

final class ImageCacheManager {
    
    static let shared = ImageCacheManager()
    private init() { }
    
    func loadImage(urlString: String, image: UIImageView) {
        guard let url = URL(string: urlString) else { return }
        image.kf.setImage(with: url,
                          placeholder: UIImage(systemName: "photo"),
                          options: [
                            .scaleFactor(UIScreen.main.scale),
                            .transition(.fade(1)),  // 애니메이션 효과
                            .cacheOriginalImage]) // 이미 캐시에 다운로드한 이미지가 있으면 가져오도록
        { result in
            switch result {
            case .success(let value):
                print("Task done for: \(value.source.url?.absoluteString ?? "")")
            case .failure(let error):
                print("Job failed: \(error.localizedDescription)")
            }
        }
        
    }
}
