//
//  HomeMapVIewController.swift
//  Popin
//
//  Created by Jihaha kim on 2024/02/04.
//

import UIKit
import MapKit
import CoreLocation

class HomeMapViewController: UIViewController, CLLocationManagerDelegate {
    private var mapView = MKMapView()
    private var cardListView: UITableView!
    private var cardCollectionView: UICollectionView!
    private let cellReuseIdentifier = "CustomCell"
    private let imageUrl = "https://placekitten.com/200/300"
    var selectedImages: Set<UIImageView> = []
    private var containerView: UIView!
    var isSelectionEnabled = false
    private var cancelButton: UIButton!
    private var selectButton: UIButton!
    private var selectedIconViews: Set<UIView> = []
    var currentLocation: CustomLocation?
    var initialLocation: CLLocation?
    
    var locationManager = CLLocationManager()
    var annotations: [CustomImageAnnotation] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setupLocationManager()
    }
    
    @objc private func mapViewTapped(_ gesture: UITapGestureRecognizer) {
        let touchPoint = gesture.location(in: mapView)
        let coordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        currentLocation = CustomLocation(currentLatitude: coordinates.latitude, currentLongitude: coordinates.longitude)
        
        if let initialLocation = initialLocation {
            let touchLocation = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
            let distance = touchLocation.distance(from: initialLocation)
            
            let thresholdDistance: CLLocationDistance = 100.0
            
            if distance <= thresholdDistance {
                let albumViewController = AlbumViewController()
                
                // todo: check params
                //                albumViewController.annotations = mapView.annotations.compactMap { $0 as? CustomImageAnnotation }
                navigationController?.pushViewController(albumViewController, animated: true)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentLocation = locations.last {
            initialLocation = currentLocation
            mapView.centerToLocation(currentLocation)
            locationManager.stopUpdatingLocation()
            setupAnnotation(location: initialLocation ?? CLLocation(latitude: 37.517496, longitude: 126.959118))
        } else {
            print("No valid location found in the update.")
        }
    }
    
    func setupAnnotation(location: CLLocation) {
        let imageUrl = "https://placekitten.com/200/300"
        let imageAnnotation = CustomImageAnnotation(coordinate: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), imageUrl: imageUrl)
        mapView.addAnnotation(imageAnnotation)
    }
    func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    func setupMapView() {
        mapView = MKMapView()
        mapView.delegate = self
        view.addSubview(mapView)
        
        mapView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.width.height.equalTo(450)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(100)
        }
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        if let currentLocation = locationManager.location {
            initialLocation = currentLocation
            mapView.centerToLocation(currentLocation)
        } else {
            initialLocation = CLLocation(latitude: 37.517496, longitude: 126.959118)
            mapView.centerToLocation(initialLocation!)
        }
        mapView.centerToLocation(initialLocation ?? CLLocation(latitude: 37.517496, longitude: 126.959118)
        )
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(mapViewTapped))
        mapView.addGestureRecognizer(tapGesture)
    }
}

extension HomeMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? CustomImageAnnotation else { return nil }
        let identifier = "customImageAnnotation"
        var view: CustomImageAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? CustomImageAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = CustomImageAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        
        return view
    }
}

