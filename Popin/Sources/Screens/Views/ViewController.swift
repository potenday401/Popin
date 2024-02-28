//
//  ViewController.swift
//  fourpin
//
//  Created by Jihaha kim on 2024/01/30.
//

import UIKit
import CoreLocation
import MapKit

class CustomImageAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let imageUrl: String

    init(coordinate: CLLocationCoordinate2D, imageUrl: String) {
        self.coordinate = coordinate
        self.imageUrl = imageUrl
    }
}

class CustomImageAnnotationView: MKAnnotationView {
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

        // 이미지를 담을 UIImageView 생성
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        imageView.layer.cornerRadius = imageView.frame.size.width / 5
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 1.0
        imageView.layer.borderColor = UIColor.white.cgColor

        // 이미지 로딩
        let url = URL(string: customAnnotation.imageUrl)
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    imageView.image = image
                }
            }
        }.resume()

        self.addSubview(imageView)
    }

}


class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    var locationManager: CLLocationManager!
    private var mapView = MKMapView()
    let initialLocation = CLLocation(latitude: 37.517496, longitude: 126.959118)
    var currentLocation: CustomLocation?
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first?.coordinate {

            currentLocation = CustomLocation(
                currentLatitude:
                    //                    Int(location.latitude),
                Int(37.517496),
                currentLongitude:
                    //                    Int(location.longitude)
                Int(126.959118)
            )
        }
    }
   
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



    
    private func setupMapView() {
        mapView = MKMapView()
        mapView.delegate = self
        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.centerToLocation(initialLocation)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupAnnotation() {
        let imageUrl = "https://placekitten.com/200/300"
        let imageAnnotation = CustomImageAnnotation(coordinate: CLLocationCoordinate2D(latitude: 37.517496, longitude: 126.959118), imageUrl: imageUrl)
        mapView.addAnnotation(imageAnnotation)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setupLocationManager()
        setupAnnotation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            self.locationManager.startUpdatingLocation()
        case .restricted, .notDetermined:
            print("GPS 권한 설정되지 않음")
        case .denied:
            print("GPS 권한 요청 거부됨")
        default:
            print("GPS: Default")
        }
    }
    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
}

private extension MKMapView {
    func centerToLocation(
        _ location: CLLocation,
        regionRadius: CLLocationDistance = 1000
    ) {
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius
        )
        setRegion(coordinateRegion, animated: true)
    }
}


struct CustomLocation {
    let currentLatitude: Int
    let currentLongitude: Int
    
    init(
        currentLatitude: Int,
        currentLongitude: Int
    ) {
        self.currentLatitude = currentLatitude
        self.currentLongitude = currentLongitude
    }
}



