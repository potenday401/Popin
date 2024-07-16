//
//  HomeMapVIewController.swift
//  Popin
//
//  Created by Jihaha kim on 2024/02/04.

import UIKit
import MapKit
import CoreLocation
import Alamofire


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
    private let geocodingService = GeocodingService()
    var lastRequestTime: Date?
    var requestInterval: TimeInterval = 10.0
    var backoffInterval: TimeInterval = 20.0
    var cache: [CLLocation: [CLPlacemark]] = [:]
    var requestQueue: [CLLocation] = []

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
        NotificationCenter.default.addObserver(self, selector: #selector(handleUploadDidFinish), name: .uploadDidFinish, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleUploadDidFinish), name: .deleteDidFinish, object: nil)
        
        setupMapView()
        setupLocationManager()
    }
    
    @objc func handleUploadDidFinish() {
        getPin(latitude: (location.coordinate.latitude), longitude: (location.coordinate.longitude))
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
                albumViewController.annotations = self.mapView.annotations.compactMap { $0 as? CustomImageAnnotation }
                navigationController?.pushViewController(albumViewController, animated: true)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        self.location = location

        DispatchQueue.main.async {
            self.mapView.centerToLocation(location)
        }

        let now = Date()
        if let lastRequestTime = lastRequestTime, now.timeIntervalSince(lastRequestTime) < requestInterval {
            requestQueue.append(location)
            return
        }
        lastRequestTime = now

        if let cachedPlacemarks = cache[location] {
            handleGeocodedLocation(cachedPlacemarks)
            processRequestQueue()
        } else {
            requestReverseGeocoding(for: location)
        }
    }
    
    func requestReverseGeocoding(for location: CLLocation) {
            geocodingService.requestReverseGeocoding(for: location) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let placemarks):
                    self.cache[location] = placemarks
                    self.handleGeocodedLocation(placemarks)
                    self.processRequestQueue()
                case .failure(let error):
                    print("Reverse geocoding failed: \(error)")
                    DispatchQueue.main.asyncAfter(deadline: .now() + self.backoffInterval) {
                        self.requestReverseGeocoding(for: location)
                    }
                }
            }
    }


    func processRequestQueue() {
        guard let nextLocation = requestQueue.first else { return }
        requestQueue.removeFirst()
        requestReverseGeocoding(for: nextLocation)
    }
    
    func handleGeocodedLocation(_ placemarks: [CLPlacemark]) {
        getPin(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    }
    
    
    func getPin(latitude: Double, longitude: Double) {
        let polygon = "POLYGON((\(longitude - 0.1) \(latitude - 0.1),\(longitude + 0.1) \(latitude - 0.1),\(longitude + 0.1) \(latitude + 0.1),\(longitude - 0.1) \(latitude + 0.1),\(longitude - 0.1) \(latitude - 0.1)))"
        let urlString = baseUrl + "contents?area=\(polygon)"
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        var request = URLRequest(url: url)
        var token = accessToken.isEmpty ? TokenManager.shared.getAccessToken() ?? "" : accessToken
        
        guard !token.isEmpty else {
            print("Access token is nil or empty")
            return
        }
        
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
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
            
            do {
                let json = try JSONSerialization.jsonObject(with: responseData, options: [])
                
                if let jsonDict = json as? [String: Any] {
                    if let jsonArray = jsonDict["responseData"] as? [[String: Any]] {
                        var photoPinContainer = [PhotoPin]()
                        
                        for pinDict in jsonArray {
                            if let photosData = pinDict["photos"] as? [String: Any],
                               let photoUrl = photosData["url"] as? String,
                               let photoId = photosData["id"] as? Int {
                                let photoPin = PhotoPin(contentId: pinDict["contentId"] as? Int ?? 0,
                                                        photoId: photoId,
                                                        title: pinDict["title"] as? String ?? "",
                                                        latitude: pinDict["latitude"] as? Double ?? 0.0,
                                                        longitude: pinDict["longitude"] as? Double ?? 0.0,
                                                        photoUrl: photoUrl,
                                                        userId: pinDict["userId"] as? String ?? "",
                                                        memorizedAt: pinDict["memorizedAt"] as? String ?? "")
                                photoPinContainer.append(photoPin)
                            } else {
                                print("Invalid pin format: \(pinDict)")
                            }
                        }
                        
                        DispatchQueue.main.async {
                            if !photoPinContainer.isEmpty {
                                self.handlePhotoPins(photoPinContainer)
                            } else {
                                self.mapView.removeAnnotations(self.mapView.annotations)
                                print("No photo pins found in the response")
                            }
                        }
                    } else if let responseData = jsonDict["responseData"] as? [String: Any] {
                        var photoPinContainer = [PhotoPin]()
                        
                        if let photosData = responseData["photos"] as? [String: Any],
                           let photoUrl = photosData["url"] as? String,
                           let photoId = photosData["id"] as? Int {
                            let photoPin = PhotoPin(contentId: responseData["contentId"] as? Int ?? 0,
                                                    photoId: photoId,
                                                    title: responseData["title"] as? String ?? "",
                                                    latitude: responseData["latitude"] as? Double ?? 0.0,
                                                    longitude: responseData["longitude"] as? Double ?? 0.0,
                                                    photoUrl: photoUrl,
                                                    userId: responseData["userId"] as? String ?? "",
                                                    memorizedAt: responseData["memorizedAt"] as? String ?? "")
                            photoPinContainer.append(photoPin)
                        } else {
                            print("Invalid single pin format: \(responseData)")
                        }
                        
                        DispatchQueue.main.async {
                            if !photoPinContainer.isEmpty {
                                self.handlePhotoPins(photoPinContainer)
                            } else {
                                self.mapView.removeAnnotations(self.mapView.annotations)
                                print("No photo pins found in the response")
                            }
                        }
                    } else {
                        print("Unexpected response format: Not a dictionary containing 'responseData'")
                    }
                } else {
                    print("Unexpected response format: Not a dictionary")
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
            let memorizedAt = pin.memorizedAt
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let coordinateKey = "\(latitude)-\(longitude)"
            
            if annotations.contains(where: { $0.contentId == contentId }) {
                       continue
            }
            
            if let count = self.pinCountByCoordinate[coordinateKey] {
                self.pinCountByCoordinate[coordinateKey] = count + 1
            } else {
                self.pinCountByCoordinate[coordinateKey] = 1
            }
            
            let pinCount = self.pinCountByCoordinate[coordinateKey, default: 0]
            currentLocationRecord = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            DispatchQueue.main.async {
                self.setupAnnotation(location: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude), imageUrl: pin.photoUrl, pinCount: pinCount, photoId: pin.photoId, contentId: pin.contentId, date: pin.memorizedAt)
                self.mapView.centerToLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
            }
            let imageAnnotation = CustomImageAnnotation(coordinate: coordinate, imageUrl: pin.photoUrl, pinCount: pinCount, photoId: photoId, contentId: pin.contentId, hidePinCountLabel: false, date: memorizedAt)
            DispatchQueue.main.async {
                self.mapView.addAnnotation(imageAnnotation)
            }
            annotations.append(imageAnnotation)
        }
    }
    
    func setupAnnotation(location: CLLocation, imageUrl: String, pinCount: Int, photoId: Int, contentId: Int, date: String) {
        let imageAnnotation = CustomImageAnnotation(coordinate: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), imageUrl: imageUrl, pinCount: pinCount, photoId: photoId, contentId: contentId, hidePinCountLabel: false, date: date)
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

extension Notification.Name {
    static let uploadDidFinish = Notification.Name("uploadDidFinish")
    static let deleteDidFinish = Notification.Name("deleteDidFinish")
}

class GeocodingService {
    private var lastRequestTime: Date?
    private let requestInterval: TimeInterval = 61.0

    func requestReverseGeocoding(for location: CLLocation, completion: @escaping (Result<[CLPlacemark], Error>) -> Void) {
        let now = Date()
        if let lastRequestTime = lastRequestTime, now.timeIntervalSince(lastRequestTime) < requestInterval {
//            completion(.failure(GEOError.throttled)) // API 제한에 걸렸을 때 적절한 오류 처리
            return
        }
        lastRequestTime = now

        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            if let error = error as NSError? {
                if error.domain == kCLErrorDomain && error.code == 2 {
//                    completion(.failure(GEOError.reverseGeocodingFailed(error)))
                    // Backoff and retry logic can be added here
                } else {
                    completion(.failure(error))
                }
            } else if let placemarks = placemarks {
                completion(.success(placemarks))
            } else {
//                completion(.failure(GEOError.unexpectedResponse))
            }
        }
    }
}

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
