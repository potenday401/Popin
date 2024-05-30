//
//  PDSCarouselView.swift
//  Popin
//
//  Created by chamsol kim on 3/29/24.
//

import UIKit
import ScalingCarousel
import SnapKit
import Kingfisher

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
        navigationBar.isUserInteractionEnabled = true
        return navigationBar
    }()
    
    private lazy var floatingButton: UIButton = {
        let button = UIButton(type: .system)
        if let chevronImage = UIImage(systemName: "chevron.down")?.withRenderingMode(.alwaysTemplate) {
            chevronImage.accessibilityIdentifier = "chevron.down"
            button.setImage(chevronImage, for: .normal)
        }
        button.tintColor = .white
        button.backgroundColor = UIColor.gray500
        button.addTarget(self, action: #selector(floatingButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Properties
    
    private let cellReuseIdentifier = "item"
    private let items: [Item]
    private let horizontalInset: CGFloat = 40
    private var floatingView: UIView?
    private weak var navigationController: UINavigationController?
    
    // MARK: - Initializer
    
    init(items: [Item], navigationController: UINavigationController?) {
        self.items = items
        self.navigationController = navigationController
        super.init(frame: .zero)
        setUpUI()
    }
    
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
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        addSubview(floatingButton)
        floatingButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)
            make.width.equalTo(42)
            make.height.equalTo(42)
        }
        floatingButton.layer.cornerRadius = 21
        floatingButton.layer.masksToBounds = true
        
        floatingView = createFloatingView()
        if let floatingView = floatingView {
            addSubview(floatingView)
            floatingView.isHidden = true
            
            floatingView.snp.makeConstraints { make in
                make.bottom.equalTo(floatingButton.snp.top).offset(-20)
                make.trailing.equalToSuperview().offset(-16)
                make.width.equalTo(156)
                make.height.equalTo(90)
            }
        }
    }
    
    private func createFloatingView() -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.gray500
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let shareImage = UIImage(named: "Share")?.withRenderingMode(.alwaysTemplate)
        let shareButton = UIButton(type: .system)
        shareButton.setTitle("공유하기", for: .normal)
        shareButton.setTitleColor(UIColor.white, for: .normal)
        shareButton.setImage(shareImage, for: .normal)
        shareButton.tintColor = .white
        shareButton.imageView?.contentMode = .scaleAspectFit
        shareButton.contentHorizontalAlignment = .left
        shareButton.semanticContentAttribute = .forceRightToLeft
        shareButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 0)
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        
        view.addSubview(shareButton)
        
        shareButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(10)
        }
        
        let deleteImage = UIImage(named: "delete")?.withRenderingMode(.alwaysTemplate)
        let deleteButton = UIButton(type: .system)
        deleteButton.setTitle("삭제하기", for: .normal)
        deleteButton.setTitleColor(UIColor.red, for: .normal)
        deleteButton.setImage(deleteImage, for: .normal)
        deleteButton.tintColor = .red
        deleteButton.imageView?.contentMode = .scaleAspectFit
        deleteButton.contentHorizontalAlignment = .left
        deleteButton.semanticContentAttribute = .forceRightToLeft
        deleteButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 0)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        
        view.addSubview(deleteButton)
        
        deleteButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-10)
        }
        return view
    }
    
    // MARK: - Lifecycle
    
    @objc
    private func backDidTap() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    private func shareButtonTapped() {
    }
    
    @objc
    private func deleteButtonTapped() {
    }
    
    @objc private func floatingButtonTapped() {
        let imageName = (floatingButton.image(for: .normal)?.accessibilityIdentifier == "chevron.down") ? "chevron.up" : "chevron.down"
        let newImage = UIImage(systemName: imageName)!
        floatingButton.setImage(newImage, for: .normal)
        
        if let floatingView = floatingView {
            floatingView.isHidden.toggle()
            if (!floatingView.isHidden) {
                UIView.transition(with: floatingButton, duration: 0.3, options: .transitionFlipFromRight, animations: nil, completion: nil)
            }
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
