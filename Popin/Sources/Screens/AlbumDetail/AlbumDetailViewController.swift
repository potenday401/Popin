//
//  AlbumDetailViewController.swift
//  fourpin
//
//  Created by Jihaha kim on 2024/01/30.
//
import UIKit
import CoreLocation

class AlbumDetailViewController: BaseViewController {
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
        label.numberOfLines = 2
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
        navigationItem.hidesBackButton = true
    }
    
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .black
        self.view = view
    }
    
    func setupHierarchy() {
        self.view.addSubview(carousel)
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

