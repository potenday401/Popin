//
//  HomeMapVIewController.swift
//  Popin
//
//  Created by Jihaha kim on 2024/02/04.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire

struct PhotoPin: Decodable {
    struct LatLng: Decodable {
        let latitude: Double
        let longitude: Double
    }

    let latLng: LatLng
    let photoUrl: String
}


class HomeMapViewController: BaseViewController, CLLocationManagerDelegate {
    weak var delegate: HomeMapViewControllerDelegate?
    func userDidSelectLocation() {
            delegate?.didSelectLocation(annotations: self.annotations)
        }

    var parentNavigationController: UINavigationController?
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
    var currentLocationRecord: CLLocation?
    var initialLocation: CLLocation?
    let baseUrl = "http://ec2-44-201-161-53.compute-1.amazonaws.com:8080/"
    var locationManager = CLLocationManager()
    var annotations: [CustomImageAnnotation] = []
    var pinCountByCoordinate: [String: Int] = [:]
    var selectedLocation: CLLocation?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setupMapView()
        setupLocationManager()
        getPin()
    }
    var getPinParameter = [
        "memberId": "member1"
    ]
    
    @objc private func mapViewTapped(_ gesture: UITapGestureRecognizer) {
        let touchPoint = gesture.location(in: mapView)
        let coordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        currentLocation = CustomLocation(currentLatitude: coordinates.latitude, currentLongitude: coordinates.longitude)

        if let currentLocationRecord = currentLocationRecord {
            let touchLocation = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
            let distance = touchLocation.distance(from: currentLocationRecord)

            let thresholdDistance: CLLocationDistance = 100.0

            if distance <= thresholdDistance {
                delegate?.didSelectLocation(annotations: self.annotations)
                let albumViewController = AlbumViewController()
                albumViewController.annotations = self.mapView.annotations.compactMap { $0 as? CustomImageAnnotation }
                navigationController?.pushViewController(albumViewController, animated: true)
            }
        }
    }

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.last != nil {
            locationManager.stopUpdatingLocation()
        } else {
            print("No valid location found in the update.")
        }
    }
    
    func getPin() {
        let url = baseUrl + "photo-pins"

        AF.request(url,
                   method: .get,
                   parameters: getPinParameter,
                   encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/json", "Accept":"application/json"])
        .validate(statusCode: 200..<300)
        .responseJSON { response in
            switch response.result {
            case .success(let value):
                if let jsonData = try? JSONSerialization.data(withJSONObject: value, options: []),
                   let photoPinContainer = try? JSONDecoder().decode([PhotoPin].self, from: jsonData) {
                    self.handlePhotoPins(photoPinContainer)
                } else {
                    print("Decoding failed.")
                    if let jsonString = String(data: value as! Data, encoding: .utf8) {
                        print("JSON String: \(jsonString)")
                    }
                }
            case .failure(let error):
                print("Network request failed with error: \(error)")
            }
        }
    }

    func handlePhotoPins(_ photoPinContainer: [PhotoPin]) {
        for pin in photoPinContainer {
            let latitude = Double(pin.latLng.latitude) ?? 0.0
            let longitude = Double(pin.latLng.longitude) ?? 0.0
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let coordinateKey = "\(pin.latLng.latitude)-\(pin.latLng.longitude)"
            
            if let count = self.pinCountByCoordinate[coordinateKey] {
                self.pinCountByCoordinate[coordinateKey] = count + 1
            } else {
                self.pinCountByCoordinate[coordinateKey] = 1
            }
            
            let pinCount = self.pinCountByCoordinate[coordinateKey, default: 0]
            currentLocationRecord = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            self.setupAnnotation(location: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude), imageUrl: pin.photoUrl, pinCount: pinCount)
            self.mapView.centerToLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
            
            let imageAnnotation = CustomImageAnnotation(coordinate: coordinate, imageUrl: pin.photoUrl, pinCount: pinCount)
            self.mapView.addAnnotation(imageAnnotation)
            annotations.append(imageAnnotation)
        }
    }

    func setupAnnotation(location: CLLocation, imageUrl: String, pinCount: Int) {
        let imageAnnotation = CustomImageAnnotation(coordinate: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), imageUrl: imageUrl, pinCount: pinCount)
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
        mapView.isUserInteractionEnabled = true
        mapView.isMultipleTouchEnabled = true
        view.addSubview(mapView)
        
        mapView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.width.equalTo(450)
            make.height.equalTo(359)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
        }
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        mapView.centerToLocation(initialLocation ?? CLLocation(latitude: 37.517496, longitude: 126.959118)
        )
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(mapViewTapped))
        tapGesture.delegate = self
        mapView.addGestureRecognizer(tapGesture)
    }
}

extension HomeMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        guard let annotation = annotation as? CustomImageAnnotation else { return nil }
        
        if let cluster = annotation as? MKClusterAnnotation {
            let clusterView = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier, for: cluster) as? MKMarkerAnnotationView
            clusterView?.titleVisibility = .visible
            clusterView?.subtitleVisibility = .visible

            // Add animation
            UIView.animate(withDuration: 0.3, animations: {
                clusterView?.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            }) { _ in
                UIView.animate(withDuration: 0.5) {
                    clusterView?.transform = CGAffineTransform.identity
                }
            }

            return clusterView
        } else {
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
}

extension HomeMapViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
