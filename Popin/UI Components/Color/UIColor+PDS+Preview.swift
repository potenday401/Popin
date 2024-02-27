//
//  UIColor+PDS+Preview.swift
//  Popin
//
//  Created by chamsol kim on 2/23/24.
//

import UIKit
import SnapKit

fileprivate final class ColorPreviewCell: UICollectionViewCell {
    
    func setColor(_ color: UIColor, name: String) {
        contentView.backgroundColor = color
        titleLabel.text = name
    }
    
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = .white
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate final class UIColorPDSPreviewViewController: UIViewController, UICollectionViewDataSource {
    
    private lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        
        let numberOfItemsInLine: CGFloat = 3
        let inset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        let spacing: CGFloat = 16
        let itemLength = (
            view.frame.width - spacing * (numberOfItemsInLine - 1) - inset.left - inset.right
        ) / numberOfItemsInLine
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        layout.sectionInset = inset
        layout.itemSize = CGSize(width: itemLength, height: itemLength)
        
        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ColorPreviewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.dataSource = self
        return collectionView
    }()
    
    struct Color {
        let name: String
        let value: UIColor
    }
    
    private let colors: [Color] = [
        Color(name: "gray100", value: UIColor.gray100),
        Color(name: "gray200", value: UIColor.gray200),
        Color(name: "gray300", value: UIColor.gray300),
        Color(name: "gray400", value: UIColor.gray400),
        Color(name: "gray500", value: UIColor.gray500),
        Color(name: "gray600", value: UIColor.gray600),
        Color(name: "indigo100", value: UIColor.indigo100),
        Color(name: "indigo200", value: UIColor.indigo200),
        Color(name: "indigo300", value: UIColor.indigo300),
        Color(name: "purple100", value: UIColor.purple100),
        Color(name: "purple200", value: UIColor.purple200),
        Color(name: "purple300", value: UIColor.purple300),
        Color(name: "pink100", value: UIColor.pink100),
        Color(name: "pink200", value: UIColor.pink200),
        Color(name: "pink300", value: UIColor.pink300),
        Color(name: "yellow100", value: UIColor.yellow100),
    ]
    
    private let cellIdentifier = "ColorCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "UIColor+PDS"
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: cellIdentifier,
            for: indexPath
        ) as? ColorPreviewCell else {
            return UICollectionViewCell()
        }
        
        let color = colors[indexPath.item]
        cell.setColor(color.value, name: color.name)
        return cell
    }
}

#Preview {
    UINavigationController(rootViewController: UIColorPDSPreviewViewController())
}
