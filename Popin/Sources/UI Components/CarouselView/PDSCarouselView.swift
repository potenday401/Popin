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
    
    private let navigationBar: PDSNavigationBar = {
        let navigationBar = PDSNavigationBar()
        navigationBar.isUserInteractionEnabled = false
        return navigationBar
    }()
    
    // MARK: - Properties
    
    private let cellReuseIdentifier = "item"
    private let items: [Item]
    private let horizontalInset: CGFloat = 40
    
    // MARK: - Initializer
    
    init(items: [Item], navigationController: UINavigationController?) {
        self.items = items
        self.navigationController = navigationController
        super.init(frame: .zero)
        setUpUI()
    }

    private let navigationController: UINavigationController?

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpUI() {
        addSubview(navigationBar)
        navigationBar.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(safeAreaLayoutGuide)
        }
        
        navigationBar.leftItem = .init(
            image: UIImage(resource: .chevronLeft),
            target: self,
            action: #selector(backDidTap)
        )
        
        addSubview(carouselView)
        carouselView.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom).offset(60)
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(0)
        }
    }

    
    // MARK: - Lifecycle
    
    @objc
    private func backDidTap() {
        navigationController?.popViewController(animated: true)
        print("back.. please")
    }
    
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
