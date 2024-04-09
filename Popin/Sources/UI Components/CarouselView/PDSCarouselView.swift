//
//  PDSCarouselView.swift
//  Popin
//
//  Created by chamsol kim on 3/29/24.
//

import UIKit
import ScalingCarousel
import SnapKit

final class PDSCarouselView<Item: UIView>: UIView, UICollectionViewDataSource {
    
    // MARK: - UI
    
    private lazy var carouselView: ScalingCarouselView = {
        let view = ScalingCarouselView(withFrame: .zero, andInset: horizontalInset)
        view.backgroundColor = .clear
        view.scrollDirection = .horizontal
        view.dataSource = self
        view.register(PDSCarouselItem.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        return view
    }()
    
    // MARK: - Properties
    
    private let cellReuseIdentifier = "item"
    private let items: [Item]
    private let horizontalInset: CGFloat = 40
    
    // MARK: - Initializer
    
    init(items: [Item]) {
        self.items = items
        super.init(frame: .zero)
        setUpUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpUI() {
        carouselView.backgroundColor = .clear
        
        addSubview(carouselView)
        carouselView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(0)
        }
    }
    
    // MARK: - Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let cellWidth = frame.width - horizontalInset * 2
        carouselView.snp.updateConstraints { make in
            make.height.equalTo(cellWidth * 1.5)
        }
    }

    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as? PDSCarouselItem else {
            return ScalingCarouselCell()
        }
        cell.addContentView(items[indexPath.item])
        return cell
    }
}
