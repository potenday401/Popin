//
//  CardListView.swift
//  Popin
//
//  Created by Jihaha kim on 2024/03/27.
//
import UIKit
import SnapKit

class CardListView: UIView {
    var cancelButton: UIButton!
    var selectButton: UIButton!
    var annotations: [CustomImageAnnotation] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCardListView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupCardListView()
    }
    
    func setupCardListView() {
        let containerView = UIView()
        addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview().offset(620)
            make.width.equalTo(400)
            make.height.equalTo(230)
        }
        selectButton = UIButton()
        selectButton.setTitle("선택", for: .normal)
        selectButton.setTitleColor(.white, for: .normal)
        selectButton.backgroundColor = .gray
        selectButton.layer.cornerRadius = 18
        selectButton.addTarget(self, action: #selector(selectButtonTapped), for: .touchUpInside)
        selectButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        
        addSubview(selectButton)
        
        selectButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(560)
            make.width.equalTo(50)
            make.height.equalTo(33)
        }
        
        cancelButton = UIButton()
        cancelButton.setTitle("취소", for: .normal)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.backgroundColor = .gray
        cancelButton.layer.cornerRadius = 18
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        
        addSubview(cancelButton)
        
        cancelButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(560)
            make.width.equalTo(50)
            make.height.equalTo(33)
        }
        
        let deleteButton: UIButton = {
            let button = UIButton()
            button.setTitle("Delete", for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = .red
            button.layer.cornerRadius = 18
            button.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            button.isHidden = true
            return button
        }()
        
        containerView.addSubview(deleteButton)
        
        deleteButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(560)
            make.trailing.equalTo(containerView.snp.trailing).offset(-16)
        }
        
        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = true
        scrollView.backgroundColor = .black
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(scrollView)
        containerView.isUserInteractionEnabled = true
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        
        scrollView.addSubview(stackView)
        scrollView.isUserInteractionEnabled = true
        let numberOfColumns = 8
        let numberOfRows = 2
        
        for _ in 0..<numberOfRows {
            let rowView = UIStackView()
            rowView.axis = .horizontal
            rowView.distribution = .fillEqually
            rowView.spacing = 0
            
            for columnIndex in 0..<numberOfColumns {
                let iconView = UIView()
                var imageUrl:URL?
                //                let imageIndex = columnIndex + 1
                for annotation in annotations {
                    imageUrl = URL(string: annotation.imageUrl)!
                }
                
                let imageView: UIImageView = {
                    let imageView = UIImageView()
                    imageView.contentMode = .scaleAspectFit
                    imageView.kf.setImage(with: imageUrl)
                    return imageView
                }()
                
                iconView.addSubview(imageView)
                imageView.snp.makeConstraints { make in
                    make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
                    make.width.equalTo(60)
                    make.height.equalTo(60)
                }
                imageView.layer.cornerRadius = 12
                imageView.layer.masksToBounds = true
                
                let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(iconViewTapped(_:)))
                iconView.addGestureRecognizer(tapGestureRecognizer)
                iconView.isUserInteractionEnabled = true
                
                rowView.addArrangedSubview(iconView)
            }
            stackView.addArrangedSubview(rowView)
            
        }
        var totalHeight = 0
        for rowView in stackView.arrangedSubviews {
            totalHeight += Int(rowView.frame.height)
        }
        
        containerView.addSubview(selectButton)
        selectButton.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.top).offset(8)
            make.trailing.equalTo(containerView.snp.trailing).offset(-16)
        }
        
        scrollView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(selectButton.snp.bottom).offset(8)
        }
        
        stackView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        scrollView.contentSize = CGSize(width: 500, height: 500)
        print("Content size:", scrollView.contentSize)
    }
    
    func updateAnnotations(_ newAnnotations: [CustomImageAnnotation]) {
        self.annotations = newAnnotations
        self.setupCardListView()
    }
    
    @objc private func selectButtonTapped() {
        //        isSelectionEnabled.toggle()
        //        guard let containerView = self.containerView else {
        //            return
        //        }
        //
        //        if isSelectionEnabled {
        //            containerView.subviews.compactMap { $0 as? UIButton }.first?.isHidden = true
        //            containerView.subviews.compactMap { $0 as? UIButton }.last?.isHidden = false
        //        } else {
        //            containerView.subviews.compactMap { $0 as? UIButton }.first?.isHidden = false
        //            containerView.subviews.compactMap { $0 as? UIButton }.last?.isHidden = true
        //        }
    }
    @objc private func cancelButtonTapped() {
        //        isSelectionEnabled = false
        //        for iconView in selectedIconViews {
        //            removeCheckmarkFromView(iconView)
        //        }
        //        selectedIconViews.removeAll()
    }
    @objc private func deleteButtonTapped() {
        //        selectedIconViews.removeAll()
        //        isSelectionEnabled = false
    }
    @objc private func iconViewTapped(_ gesture: UITapGestureRecognizer) {
        //        guard isSelectionEnabled,
        //              let iconView = gesture.view else {
        //            return
        //        }
        //        let checkmarkTag = 100
        //
        //        if selectedIconViews.contains(iconView) {
        //            selectedIconViews.remove(iconView)
        //            removeCheckmarkFromView(iconView)
        //        } else {
        //            selectedIconViews.insert(iconView)
        //            let checkmarkImageView = UIImageView(image: UIImage(named: "checkbox"))
        //            checkmarkImageView.tintColor = .blue
        //            checkmarkImageView.contentMode = .scaleAspectFit
        //            checkmarkImageView.tag = checkmarkTag
        //            iconView.addSubview(checkmarkImageView)
        //            checkmarkImageView.snp.makeConstraints { make in
        //                make.trailing.bottom.equalToSuperview().inset(15)
        //                make.width.height.equalTo(24)
        //            }
        //        }
    }
}
