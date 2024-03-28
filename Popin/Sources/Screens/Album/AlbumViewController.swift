//
//  AlbumViewController.swift
//  fourpin
//
//  Created by Jihaha kim on 2024/01/30.
import UIKit
import CoreLocation
import MapKit
import SnapKit
import Kingfisher

final class CustomImageAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let imageUrl: String
    var pinCount: Int = 0
    
    init(coordinate: CLLocationCoordinate2D, imageUrl: String, pinCount: Int) {
        self.coordinate = coordinate
        self.imageUrl = imageUrl
        self.pinCount = pinCount
    }
}

final class AlbumViewController: BaseViewController, AlbumHeaderViewDelegate {
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
    var annotationImage: String?
    var currentLocationRecord: CLLocation?
    var locationManager: CLLocationManager!
    private var mapView = MKMapView()
    var annotations: [CustomImageAnnotation] = []
    var locationString:String = ""
    let cardListView = CardListView()
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func plusButtonTapped() {
        //        let cameraViewController = CameraViewController()
        //        cameraViewController.initialLocation = initialLocation
        //        navigationController?.pushViewController(cameraViewController, animated: true)
    }
    
    private lazy var navigationBar: PDSNavigationBar = {
        let navigationBar = PDSNavigationBar()
        navigationBar.title = self.locationString
        return navigationBar
    }()
    
    func setupStatusBarView() {
        let statusBarView = UIView()
        
        view.addSubview(statusBarView)
        
        let infoView = AlbumInfoView()
        statusBarView.addSubview(infoView)
        
        statusBarView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(163)
        }
        
        infoView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-10)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(0)
        }
    }
    
    func setupMapView() {
        mapView = MKMapView()
        mapView.delegate = self
        view.addSubview(mapView)
        mapView.backgroundColor = .red
        mapView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.width.height.equalTo(359)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(130)
        }
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(mapViewTapped))
        mapView.addGestureRecognizer(tapGesture)
        mapView.isUserInteractionEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(navigationBar)
        navigationBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
        }
        
        navigationBar.leftItem = .init(
            image: UIImage(resource: .chevronLeft),
            target: self,
            action: #selector(backButtonTapped)
        )
        
        navigationBar.rightItem = .init(
            image: UIImage(resource: .plus),
            target: self,
            action: #selector(plusButtonTapped)
        )
        setupLocationManager()
        setupMapView()
        // check scroll
        view.addSubview(cardListView)
        cardListView.updateAnnotations(annotations)
        setupStatusBarView()
        isSelectionEnabled = true
        navigationItem.hidesBackButton = true
    }
    
    @objc private func selectButtonTapped() {
        isSelectionEnabled.toggle()
        guard let containerView = self.containerView else {
            return
        }
        
        if isSelectionEnabled {
            containerView.subviews.compactMap { $0 as? UIButton }.first?.isHidden = true
            containerView.subviews.compactMap { $0 as? UIButton }.last?.isHidden = false
        } else {
            containerView.subviews.compactMap { $0 as? UIButton }.first?.isHidden = false
            containerView.subviews.compactMap { $0 as? UIButton }.last?.isHidden = true
        }
    }
    
    @objc private func cancelButtonTapped() {
        isSelectionEnabled = false
        for iconView in selectedIconViews {
            removeCheckmarkFromView(iconView)
        }
        selectedIconViews.removeAll()
    }
    
    @objc private func deleteButtonTapped() {
        selectedIconViews.removeAll()
        isSelectionEnabled = false
    }
    
    private func removeCheckmarkFromView(_ iconView: UIView) {
        if let checkmarkImageView = iconView.viewWithTag(100) as? UIImageView {
            checkmarkImageView.removeFromSuperview()
        }
    }
    
    @objc private func iconViewTapped(_ gesture: UITapGestureRecognizer) {
        guard isSelectionEnabled,
              let iconView = gesture.view else {
            return
        }
        let checkmarkTag = 100
        
        if selectedIconViews.contains(iconView) {
            selectedIconViews.remove(iconView)
            removeCheckmarkFromView(iconView)
        } else {
            selectedIconViews.insert(iconView)
            let checkmarkImageView = UIImageView(image: UIImage(named: "checkbox"))
            checkmarkImageView.tintColor = .blue
            checkmarkImageView.contentMode = .scaleAspectFit
            checkmarkImageView.tag = checkmarkTag
            iconView.addSubview(checkmarkImageView)
            checkmarkImageView.snp.makeConstraints { make in
                make.trailing.bottom.equalToSuperview().inset(15)
                make.width.height.equalTo(24)
            }
        }
    }
}


extension MKMapView {
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
    let currentLatitude: Double
    let currentLongitude: Double
    
    init(
        currentLatitude: Double,
        currentLongitude: Double
    ) {
        self.currentLatitude = currentLatitude
        self.currentLongitude = currentLongitude
    }
}

protocol AlbumHeaderViewDelegate: AnyObject {
    func plusButtonTapped()
    func backButtonTapped()
}

extension AlbumViewController: MKMapViewDelegate {
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
    
    @objc private func mapViewTapped(_ gesture: UITapGestureRecognizer) {
        // 일단 이동... todo: 모든 annotation 이동 가능하게
        let albumDetailViewController = AlbumDetailViewController()
        albumDetailViewController.annotations = mapView.annotations.compactMap { $0 as? CustomImageAnnotation }
        navigationController?.pushViewController(albumDetailViewController, animated: true)
        let touchPoint = gesture.location(in: mapView)
        let coordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        currentLocation = CustomLocation(currentLatitude: coordinates.latitude, currentLongitude: coordinates.longitude)
        
        if let currentLocationRecord = currentLocationRecord {
            let touchLocation = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
            let distance = touchLocation.distance(from: currentLocationRecord)
            
            let thresholdDistance: CLLocationDistance = 100.0
            
            if distance <= thresholdDistance {
                let albumDetailViewController = AlbumDetailViewController()
                albumDetailViewController.annotations = mapView.annotations.compactMap { $0 as? CustomImageAnnotation }
                navigationController?.pushViewController(albumDetailViewController, animated: true)
            }
        }
    }
    
    func setupAnnotation(location: CLLocation, imageUrl: String) {
        let imageAnnotation = CustomImageAnnotation(coordinate: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), imageUrl: imageUrl, pinCount: 2)
        mapView.addAnnotation(imageAnnotation)
    }
}

extension AlbumViewController: CLLocationManagerDelegate {
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for annotation in annotations {
            let coordinate = CLLocationCoordinate2D(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            mapView.centerToLocation(location)
            currentLocationRecord = location
            setupAnnotation(location: location, imageUrl: annotation.imageUrl)
        }
        
        if locations.last != nil {
            locationManager.stopUpdatingLocation()
        } else {
            print("No valid location found in the update.")
        }
    }
    
    func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
}

