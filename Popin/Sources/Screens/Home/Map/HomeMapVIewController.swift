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

struct PhotoPin: Codable {
    let contentId: Int
    let photoId: Int
    let title: String
    let latitude: Double
    let longitude: Double
    let photoUrl: String
    let userId: String
    let memorizedAt: String
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
    private let imageUrl = ""
    var selectedImages: Set<UIImageView> = []
    private var containerView: UIView!
    var isSelectionEnabled = false
    private var cancelButton: UIButton!
    private var selectButton: UIButton!
    private var selectedIconViews: Set<UIView> = []
    var currentLocation: CustomLocation?
    var currentLocationRecord: CLLocation?
    var initialLocation: CLLocation?
    var location = CLLocation(latitude: 0, longitude: 0)
    let baseUrl = "http://dev-api-popin.ap-northeast-2.elasticbeanstalk.com/"
    var locationManager = CLLocationManager()
    var annotations: [CustomImageAnnotation] = []
    var pinCountByCoordinate: [String: Int] = [:]
    var selectedLocation: CLLocation?
    
    private let accessToken: String
    
    init(accessToken: String) {
        self.accessToken = accessToken
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setupLocationManager()
    }
    
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
                let albumViewController = AlbumViewController(accessToken: accessToken)
                //todo: check whole customImageAnnotation to albumView
                albumViewController.annotations = self.mapView.annotations.compactMap { $0 as? CustomImageAnnotation }
                navigationController?.pushViewController(albumViewController, animated: true)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first!
        mapView.centerToLocation(location)
        getPin(latitude: (location.coordinate.latitude), longitude: (location.coordinate.longitude))
        if locations.last != nil {
            locationManager.stopUpdatingLocation()
        } else {
            print("No valid location found in the update1.")
        }
    }
    
    func getPin(latitude: Double, longitude: Double) {
        let polygon =
        "POLYGON((\(longitude - 0.1) \(latitude - 0.1),\(longitude + 0.1) \(latitude - 0.1),\(longitude + 0.1) \(latitude + 0.1),\(longitude - 0.1) \(latitude + 0.1),\(longitude - 0.1) \(latitude - 0.1)))"
        print(polygon, "polygon")
        let urlString = baseUrl + "contents?area=\(polygon)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network request failed with error: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                return
            }
            
            guard 200..<300 ~= httpResponse.statusCode else {
                print("Invalid status code: \(httpResponse.statusCode)")
                return
            }
            
            guard let responseData = data else {
                print("No data received")
                return
            }
            guard let jsonData = try? JSONSerialization.jsonObject(with: responseData) else {
                print("Failed to convert JSON data")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: responseData, options: [])
                if let jsonDict = json as? [String: Any],
                   let jsonArray = jsonDict["responseData"] as? [[String: Any]] {
                    var photoPinContainer = [PhotoPin]()
                    var photoIds:Int = 0
                    var photoImageUrl:String = ""
                    let dateFormatter: DateFormatter = {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
                        return formatter
                    }()
                    
                    for pinDict in jsonArray {
                        if let photosData = pinDict["photos"] as? [String: Any] {
                            if let photoUrl = photosData["url"] as? String {
                                photoImageUrl = photoUrl
                            } else {
                                print("url not found or not an String")
                            }
                            if let photoId = photosData["id"] as? Int {
                                photoIds = photoId
                            } else {
                                print("ID not found or not an Int")
                            }
                        } else {
                            print("Photos data is not a dictionary or is nil")
                        }
                        guard let contentId = pinDict["contentId"] as? Int,
                              let title = pinDict["title"] as? String,
                              let latitude = pinDict["latitude"] as? Double,
                              let longitude = pinDict["longitude"] as? Double,
                              let userId = pinDict["userId"] as? String,
                              let memorizedAtString = pinDict["memorizedAt"] as? String else {
                            print("Failed to decode photo pin: \(pinDict)")
                            continue
                        }
                        
                        let photoPin = PhotoPin(contentId: contentId, photoId: photoIds, title: title, latitude: latitude, longitude: longitude, photoUrl: photoImageUrl, userId: userId, memorizedAt: memorizedAtString)
                        photoPinContainer.append(photoPin)
                    }
                    
                    if !photoPinContainer.isEmpty {
                        self.handlePhotoPins(photoPinContainer)
                    } else {
                        print("No photo pins found in the response")
                    }
                } else {
                    print("Unexpected response format: Not an array of dictionaries")
                }
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }
        task.resume()
    }
    
    func handlePhotoPins(_ photoPinContainer: [PhotoPin]) {
        for pin in photoPinContainer {
            let latitude = pin.latitude
            let longitude = pin.longitude
            let photoId = pin.photoId
            let contentId = pin.contentId
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let coordinateKey = "\(latitude)-\(longitude)"
            
            if let count = self.pinCountByCoordinate[coordinateKey] {
                self.pinCountByCoordinate[coordinateKey] = count + 1
            } else {
                self.pinCountByCoordinate[coordinateKey] = 1
            }
            
            let pinCount = self.pinCountByCoordinate[coordinateKey, default: 0]
            currentLocationRecord = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            self.setupAnnotation(location: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude), imageUrl: pin.photoUrl, pinCount: pinCount, photoId: pin.photoId, contentId: pin.contentId)
            self.mapView.centerToLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
            let imageAnnotation = CustomImageAnnotation(coordinate: coordinate, imageUrl: pin.photoUrl, pinCount: pinCount, photoId: photoId, contentId: pin.contentId, hidePinCountLabel: false)
            DispatchQueue.main.async {
                self.mapView.addAnnotation(imageAnnotation)
            }
            annotations.append(imageAnnotation)
        }
    }
    
    func setupAnnotation(location: CLLocation, imageUrl: String, pinCount: Int, photoId: Int, contentId: Int) {
        let imageAnnotation = CustomImageAnnotation(coordinate: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), imageUrl: imageUrl, pinCount: pinCount, photoId: photoId, contentId: contentId, hidePinCountLabel: false)
        DispatchQueue.main.async {
            self.mapView.addAnnotation(imageAnnotation)
        }
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
