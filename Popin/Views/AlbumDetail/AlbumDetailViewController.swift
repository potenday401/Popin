//
//  AlbumDetailViewController.swift
//  fourpin
//
//  Created by Jihaha kim on 2024/01/30.
//
import UIKit
import CoreLocation

class AlbumDetailViewController: UIViewController {
    var annotations: [CustomImageAnnotation] = []



    lazy var carousel: Carousel = {
        let urls = annotations.map { URL(string: $0.imageUrl) }.compactMap { $0 }
        let carousel = Carousel(frame: .zero, urls: urls, annotations: annotations)
        carousel.delegate = self
        return carousel
    }()

    let locationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 0 // Allow multiple lines if needed
        label.text = "Default Location"
        return label
    }()

    func updateLocationLabel(with annotation: CustomImageAnnotation) {
        let location = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)

        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarchy()
        if let firstAnnotation = annotations.first {
            updateLocationLabel(with: firstAnnotation)
        }
        setupComponents()
        setupConstraints()
//        locationLabel.isHidden = false
//        locationLabel.backgroundColor = .red // or any other color
//        locationLabel.frame = CGRect(x: 16, y: 100, width: 200, height: 30)
    }

    override func loadView() {
        let view = UIView()
        view.backgroundColor = .black
        self.view = view
    }

    func setupHierarchy() {
        self.view.addSubview(carousel)
//        self.view.addSubview(locationLabel)
    }

    func setupComponents() {
        carousel.translatesAutoresizingMaskIntoConstraints = false
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            carousel.topAnchor.constraint(equalTo: view.topAnchor),
            carousel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            carousel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            carousel.trailingAnchor.constraint(equalTo: view.trailingAnchor),

//            locationLabel.topAnchor.constraint(equalTo: carousel.bottomAnchor, constant: 16),
//            locationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            locationLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
}

extension AlbumDetailViewController: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentIndex = Int(scrollView.contentOffset.x / carousel.frame.width)

        if currentIndex >= 0 && currentIndex < annotations.count {
            let currentAnnotation = annotations[currentIndex]
            updateLocationLabel(with: currentAnnotation)
        }
    }
}

