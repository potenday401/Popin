//
//  CustomCollectionViewCell.swift
//  Popin
//
//  Created by Jihaha kim on 2024/02/01.
//
import UIKit

class CustomCollectionViewCell: UICollectionViewCell {
    private var imageView: UIImageView!
    private var label: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    func configure(imageUrl: String, text: String) {
        loadImage(from: "https://placekitten.com/200/300")
        label.text = text
    }

    private func setupViews() {
        // Set up image view
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        addSubview(imageView)

        // Set up label
        label = UILabel()
        label.textAlignment = .center
        addSubview(label)

        // Add constraints
        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(label.snp.top)
        }

        label.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(30)
        }
    }

    private func loadImage(from imageUrl: String) {
        guard let url = URL(string: imageUrl) else { return }
        URLSession.shared.dataTask(with: url) { [weak self] (data, _, _) in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.imageView.image = image
                }
            }
        }.resume()
    }
}
