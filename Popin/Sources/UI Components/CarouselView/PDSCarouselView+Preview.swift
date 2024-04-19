//
//  PDSCarouselView+Preview.swift
//  Popin
//
//  Created by chamsol kim on 3/29/24.
//

import UIKit
import SnapKit

fileprivate class PhotoView: UIView {
    
    private let imageView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        imageView.backgroundColor = .blue
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(75)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate final class PDSCarouselViewPreviewView: UIViewController {
    
    private let itemViews = [
        PhotoView(),
        PhotoView(),
        PhotoView(),
        PhotoView(),
        PhotoView(),
        PhotoView(),
        PhotoView(),
    ]
    
//    private lazy var carouselView = PDSCarouselView(items: itemViews)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
//        view.addSubview(carouselView)
//        carouselView.snp.makeConstraints { make in
//            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
//        }
    }
}

#Preview {
    PDSCarouselViewPreviewView()
}
