//
//  CarouselLayout.swift
//  Popin
//
//  Created by Jihaha kim on 2024/02/03.
//
import UIKit

final class CarouselLayout: UICollectionViewFlowLayout {
    override init() {
        super.init()
        self.minimumInteritemSpacing = 0
        self.minimumLineSpacing = -10
        self.scrollDirection = .horizontal
        self.sectionInset = .zero
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView, let superAttributes = super.layoutAttributesForElements(in: rect) else {
            return super.layoutAttributesForElements(in: rect)
        }
        
        let centerX = collectionView.contentOffset.x + collectionView.bounds.width / 2
        
        for attributes in superAttributes {
            let position = attributes.center.x - centerX
            let scale = 1 - abs(position) / collectionView.bounds.width * 0.4 // 크기를 더 작게 조절합니다.
            attributes.transform = CGAffineTransform(scaleX: scale, y: scale)
            attributes.zIndex = Int(position) // z-index를 position에 비례하도록 설정합니다.
        }
        
        return superAttributes
    }

    override func prepare() {
        super.prepare()
        if let collectionView = collectionView {
            let collectionViewWidth = collectionView.bounds.width
            let collectionViewHeight = collectionView.bounds.height
            let itemWidth: CGFloat = collectionViewWidth * 0.7 // 아이템의 너비를 더 작게 조정합니다.
            let itemHeight: CGFloat = collectionViewHeight * 0.5 // 아이템의 높이를 더 작게 조정합니다.
            let sideItemSpacing: CGFloat = (collectionViewWidth - itemWidth) / 4 // 아이템 간격을 조정합니다.
            let minimumLineSpacing: CGFloat = sideItemSpacing // 최소 줄 간격을 아이템 간격과 동일하게 설정합니다.
            
            itemSize = CGSize(width: itemWidth, height: itemHeight)
            
            sectionInset = UIEdgeInsets(top: 0, left: sideItemSpacing, bottom: 0, right: sideItemSpacing)
            
            self.minimumLineSpacing = minimumLineSpacing // 최소 줄 간격을 설정합니다.
            
            collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        }
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard itemSize != newBounds.size else { return false }
        itemSize = newBounds.size
        return true
    }
}

