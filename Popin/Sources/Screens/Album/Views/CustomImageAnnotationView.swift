//
//  CustomImageAnnotationView.swift
//  Popin
//
//  Created by Jihaha kim on 2024/03/26.
//

import MapKit

final class CustomImageAnnotationView: MKAnnotationView {
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    private func setupViews() {
        guard let customAnnotation = self.annotation as? CustomImageAnnotation else {
            return
        }

        let imageView = UIImageView()
        imageView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        imageView.layer.cornerRadius = imageView.frame.size.width / 5
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 1.0
        imageView.layer.borderColor = UIColor.white.cgColor
        self.isUserInteractionEnabled = true
        imageView.isUserInteractionEnabled = true
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        imageView.addGestureRecognizer(tap)
        
        // countLabel load속도 체크필요
        let countLabel = UILabel()
        countLabel.text = "\(customAnnotation.pinCount)"
        countLabel.textColor = .white
        countLabel.font = UIFont.systemFont(ofSize: 14)
        countLabel.textAlignment = .center
        countLabel.backgroundColor = .indigo200
        countLabel.layer.cornerRadius = 15
        countLabel.clipsToBounds = true
        
        guard let url = URL(string: customAnnotation.imageUrl) else {
            imageView.image = UIImage(named: "defaultImage")
            countLabel.frame = CGRect(x: imageView.frame.maxX + 5, y: imageView.frame.origin.y + 7.5, width: 33, height: 33)
            self.addSubview(imageView)
            self.addSubview(countLabel)
            return
        }

        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    imageView.image = image
                }
            }
        }.resume()
        DispatchQueue.main.async {
            self.addSubview(imageView)
            self.addSubview(countLabel)
        }
    }
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        print("dkdkdkdkd")
    }
    
    }
