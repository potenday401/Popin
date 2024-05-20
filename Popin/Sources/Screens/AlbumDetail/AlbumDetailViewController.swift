//
//  AlbumDetailViewController.swift
//  fourpin
//
//  Created by Jihaha kim on 2024/01/30.
//
import UIKit
import Kingfisher
import CoreLocation

class AlbumDetailViewController: BaseViewController {
    
    var annotations: [CustomImageAnnotation] = []
    
    lazy var carousel: PDSCarouselView<UIView> = {
        let urls = annotations.map { URL(string: $0.imageUrl) }.compactMap { $0 }
        
        let views: [UIView] = urls.map { url in
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholder"))
            return imageView
        }
        let carousel = PDSCarouselView(items: views, navigationController: navigationController)
        return carousel
    }()
    
    let locationIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "date")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let dateIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "pin")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    // todo: default Location, default Date실데이터로 변경
    let locationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 2
        label.text = "수원시 동작구"
        return label
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "23.12.08"
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarchy()
        navigationItem.hidesBackButton = true
    }

    override func loadView() {
        let view = UIView()
        view.backgroundColor = .black
        self.view = view
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupComponents()
        setupConstraints()
    }
    
    func setupHierarchy() {
        view.addSubview(carousel)
        view.addSubview(locationIcon)
        view.addSubview(locationLabel)
        view.addSubview(dateIcon)
        view.addSubview(dateLabel)
    }
    
    func setupComponents() {
        carousel.translatesAutoresizingMaskIntoConstraints = false
        locationIcon.translatesAutoresizingMaskIntoConstraints = false
        dateIcon.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            carousel.topAnchor.constraint(equalTo: view.topAnchor),
            carousel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            carousel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            carousel.heightAnchor.constraint(equalTo: carousel.widthAnchor, multiplier: 1.5),
            locationIcon.topAnchor.constraint(equalTo: carousel.bottomAnchor, constant: 8),
            locationIcon.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            locationIcon.widthAnchor.constraint(equalToConstant: 24),
            locationIcon.heightAnchor.constraint(equalToConstant: 24),
            
            locationLabel.centerYAnchor.constraint(equalTo: locationIcon.centerYAnchor),
            locationLabel.leadingAnchor.constraint(equalTo: locationIcon.trailingAnchor, constant: 8),
            locationLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            dateIcon.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 8),
            dateIcon.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            dateIcon.widthAnchor.constraint(equalToConstant: 24),
            dateIcon.heightAnchor.constraint(equalToConstant: 24),
            
            dateLabel.centerYAnchor.constraint(equalTo: dateIcon.centerYAnchor),
            dateLabel.leadingAnchor.constraint(equalTo: dateIcon.trailingAnchor, constant: 8),
            dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
}

extension AlbumDetailViewController: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentIndex = Int(scrollView.contentOffset.x / carousel.frame.width)
        
        if currentIndex >= 0 && currentIndex < annotations.count {
            let currentAnnotation = annotations[currentIndex]
            updateLocationLabel(with: currentAnnotation)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let currentDate = formatter.string(from: Date())
            dateLabel.text = currentDate
        }
    }
    
    private func updateLocationLabel(with annotation: CustomImageAnnotation) {
        let location = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            if let placemark = placemarks?.first {
                var locationString = ""
                
                if let locality = placemark.locality {
                    locationString += locality
                }
                
                if let sublocality = placemark.subLocality {
                    if !locationString.isEmpty {
                        locationString += ", "
                    }
                    locationString += sublocality
                }
                self.locationLabel.text = locationString.isEmpty ? "Unknown Location" : locationString
            } else {
                self.locationLabel.text = "Unknown Location"
            }
        }
    }
}
