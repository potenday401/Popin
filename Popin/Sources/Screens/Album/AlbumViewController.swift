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
import Photos

class IconView: UIView {
    var photoId: Int
    var contentId: Int
    
    init(photoId: Int, contentId: Int) {
        self.photoId = photoId
        self.contentId = contentId
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CustomImageAnnotation: MKPointAnnotation {
    var imageUrl: String
    var pinCount: Int
    var photoId:Int
    var contentId:Int
    var hidePinCountLabel: Bool = false
    var date: String
    
    init(coordinate: CLLocationCoordinate2D, imageUrl: String, pinCount: Int, photoId: Int, contentId: Int, hidePinCountLabel:Bool, date: String) {
        self.imageUrl = imageUrl
        self.pinCount = pinCount
        self.photoId = photoId
        self.contentId = contentId
        self.hidePinCountLabel = hidePinCountLabel
        self.date = date
        super.init()
        self.coordinate = coordinate
    }
}

final class AlbumViewController: BaseViewController, AlbumHeaderViewDelegate {
    private var cardCollectionView: UICollectionView!
    private let cellReuseIdentifier = "CustomCell"
    private let imageUrl = ""
    var selectedImages: Set<UIImageView> = []
    private var containerView: UIView!
    var isSelectionEnabled = false
    private var cancelButton: UIButton!
    private var selectButton: UIButton!
    private var imageView: UIImageView?
    private var selectedIconViews: Set<UIView> = []
    var currentLocation: CustomLocation?
    var initialLocation: CLLocation?
    var annotationImage: String?
    var currentLocationRecord: CLLocation?
    var locationManager: CLLocationManager!
    private var mapView = MKMapView()
    var annotations: [CustomImageAnnotation] = []
    var locationString:String = ""
    private let accessToken: String
    weak var viewController: UIViewController?
    private var annotationsAlreadyAdded = false
    var existingAnnotations: [CustomImageAnnotation] = []
    private var isMapCentered = false
    private var infoView: AlbumInfoView?
    private var geocodingCache = [CLLocation: CLPlacemark]()
    private var geocoder = CLGeocoder()

    init(accessToken: String) {
        self.accessToken = accessToken
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let deleteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(resource: .trash), for: .normal)
        button.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    @objc func backButtonTapped() {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func cameraAuth() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted {
                print("권한 허용")
            } else {
                print("권한 거부")
            }
        }
    }
    
    @objc
    func plusButtonTapped() {
        cameraAuth()
    }
    
    private lazy var navigationBar: PDSNavigationBar = {
        let navigationBar = PDSNavigationBar()
        navigationBar.isUserInteractionEnabled = true
        navigationBar.title = self.locationString
        return navigationBar
    }()
    
    func setupStatusBarView() {
        let statusBarView = UIView()
        view.addSubview(statusBarView)
        let infoView = AlbumInfoView(pinCount: annotations.count)
        statusBarView.addSubview(infoView)
        
        statusBarView.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().offset(120)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(33)
        }
        
        infoView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-10)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(0)
        }
        self.infoView = infoView
    }
    
    func setupMapView() {
        mapView = MKMapView()
        mapView.delegate = self
        view.addSubview(mapView)
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
    
    private func setupCardListView() {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(480)
            make.width.equalTo(400)
            make.height.equalTo(200)
        }
        
        selectButton = UIButton()
        selectButton.setTitle("선택", for: .normal)
        selectButton.setTitleColor(.white, for: .normal)
        selectButton.backgroundColor = .gray
        selectButton.layer.cornerRadius = 18
        selectButton.addTarget(self, action: #selector(selectButtonTapped), for: .touchUpInside)
        selectButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        
        containerView.addSubview(selectButton)
        
        selectButton.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.top).offset(25)
            make.trailing.equalTo(containerView.snp.trailing).offset(-326)
            make.width.equalTo(50)
            make.height.equalTo(33)
        }
        
        cancelButton = UIButton()
        cancelButton.setTitle("취소", for: .normal)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.backgroundColor = .gray
        cancelButton.layer.cornerRadius = 18
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        
        containerView.addSubview(cancelButton)
        cancelButton.isHidden = true
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.top).offset(25)
            make.trailing.equalTo(containerView.snp.trailing).offset(-326)
            make.width.equalTo(50)
            make.height.equalTo(33)
        }
        
        containerView.addSubview(deleteButton)
        deleteButton.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.top).offset(25)
            make.trailing.equalTo(containerView.snp.trailing).offset(-16)
        }
        
        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = true
        scrollView.backgroundColor = .black
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(scrollView)
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        
        scrollView.addSubview(stackView)
        
        scrollView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(selectButton.snp.bottom).offset(8)
        }
        stackView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        let maxImagesPerColumn = 2
        var currentRowStackView: UIStackView?
        var rowIndex = 0
        
        for (index, annotation) in annotations.enumerated() {
            if index % maxImagesPerColumn == 0 {
                currentRowStackView = UIStackView()
                currentRowStackView?.axis = .vertical
                currentRowStackView?.distribution = .fillEqually
                currentRowStackView?.spacing = 8
                stackView.addArrangedSubview(currentRowStackView!)
                rowIndex += 1
            }
            
            let iconView = IconView(photoId: annotation.photoId, contentId: annotation.contentId)
            
            let imageView: UIImageView = {
                let imageView = UIImageView()
                imageView.contentMode = .scaleAspectFit
                if let url = URL(string: annotation.imageUrl) {
                    imageView.kf.setImage(with: url)
                }
                return imageView
            }()
            
            iconView.addSubview(imageView)
            imageView.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8,
                                                                 left: 8, bottom: 8, right: 8))
                make.width.equalTo(86)
                make.height.equalTo(86)
            }
            imageView.layer.cornerRadius = 12
            imageView.layer.masksToBounds = true
            
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(iconViewTapped(_:)))
            iconView.addGestureRecognizer(tapGestureRecognizer)
            iconView.isUserInteractionEnabled = true
            
            currentRowStackView?.addArrangedSubview(iconView)
        }
        
        if annotations.count % maxImagesPerColumn != 0 {
            for _ in 0..<(maxImagesPerColumn - annotations.count % maxImagesPerColumn) {
                let emptyView = UIView()
                currentRowStackView?.addArrangedSubview(emptyView)
            }
        }
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
        setupCardListView()
        setupStatusBarView()
        isSelectionEnabled = true
        navigationItem.hidesBackButton = true
        NotificationCenter.default.addObserver(self, selector: #selector(handleDeleteDidFinishNotification), name: .deleteDidFinish, object: nil)
    }
    
    
    @objc private func handleDeleteDidFinishNotification() {
        mapView.removeAnnotations(mapView.annotations)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
        selectButton.isHidden = false
        cancelButton.isHidden = true
        deleteButton.isHidden = true
        isSelectionEnabled = false
        for iconView in selectedIconViews {
            removeCheckmarkFromView(iconView)
        }
        selectedIconViews.removeAll()
    }
    
    @objc private func deleteButtonTapped() {
        for iconView in selectedIconViews {
            guard let iconView = iconView as? IconView else { continue }
            let photoId = iconView.photoId
            let contentId = iconView.contentId
            deleteResource(with: photoId, and: contentId)
        }
        selectedIconViews.removeAll()
        cancelButton.isHidden = true
        deleteButton.isHidden = true
        selectButton.isHidden = false
    }
    
    private func deleteResource(with photoId: Int, and contentId: Int) {
        guard let photoUrl = URL(string: "http://dev-api-popin.ap-northeast-2.elasticbeanstalk.com/photos/\(photoId)") else { return }
        guard let contentUrl = URL(string: "http://dev-api-popin.ap-northeast-2.elasticbeanstalk.com/contents/\(contentId)") else { return }
        
        var photoRequest = URLRequest(url: photoUrl)
        photoRequest.httpMethod = "DELETE"
        photoRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        photoRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        var contentRequest = URLRequest(url: contentUrl)
        contentRequest.httpMethod = "DELETE"
        contentRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        contentRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let photoTask = URLSession.shared.dataTask(with: photoRequest) { data, response, error in
            if let error = error {
                print("Error deleting photo: \(error)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    if let index = self.annotations.firstIndex(where: { $0.photoId == photoId }) {
                        let removedAnnotation = self.annotations.remove(at: index)
                        self.mapView.removeAnnotation(removedAnnotation)
                        self.setupCardListView()
                        self.infoView?.updatePhotoCount(self.annotations.count)
                    }
                    NotificationCenter.default.post(name: .deleteDidFinish, object: nil)
                }
                print("Successfully deleted photo with id \(photoId)")
            } else {
                print(response, "Failed to delete photo with id \(photoId)")
            }
        }
        
        let contentTask = URLSession.shared.dataTask(with: contentRequest) { data, response, error in
            if let error = error {
                print("Error deleting content: \(error)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    if let index = self.annotations.firstIndex(where: { $0.contentId == contentId }) {
                        let removedAnnotation = self.annotations.remove(at: index)
                        self.mapView.removeAnnotation(removedAnnotation)
                        self.setupCardListView()
                        self.infoView?.updatePhotoCount(self.annotations.count)
                    }
                }
                print("Successfully deleted content with id \(contentId)")
            } else {
                print(response, "Failed to delete content with id \(contentId)")
            }
        }
        photoTask.resume()
        contentTask.resume()
    }
    
    
    private func removeAnnotation(with photoId: Int) {
        if let index = annotations.firstIndex(where: { $0.photoId == photoId }) {
            let annotation = annotations.remove(at: index)
            mapView.removeAnnotation(annotation)
        }
    }
    
    private func refreshAnnotations() {
        mapView.removeAnnotations(mapView.annotations)
        
        for annotation in annotations {
            setupAnnotation(location: CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude), imageUrl: annotation.imageUrl, pinCount: annotation.pinCount, photoId: annotation.photoId, contentId: annotation.contentId, date:annotation.date)
        }
    }
    
    private func removeCheckmarkFromView(_ iconView: UIView) {
        if let checkmarkImageView = iconView.viewWithTag(100) as? UIImageView {
            checkmarkImageView.removeFromSuperview()
        }
    }
    
    @objc private func iconViewTapped(_ gesture: UITapGestureRecognizer) {
        guard isSelectionEnabled,
              let iconView = gesture.view as? IconView else {
            return
        }
        
        let checkmarkTag = 100
        
        if selectedIconViews.contains(iconView) {
            selectedIconViews.remove(iconView)
            removeCheckmarkFromView(iconView)
            if selectedIconViews.isEmpty {
                deleteButton.isHidden = true
                selectButton.isHidden = false
                cancelButton.isHidden = true
            }
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
            deleteButton.isHidden = false
            selectButton.isHidden = true
            cancelButton.isHidden = false
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
        DispatchQueue.main.async {
            self.setRegion(coordinateRegion, animated: true)
        }
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
    
    func reverseGeocode(location: CLLocation, completion: @escaping (CLPlacemark?) -> Void) {
            if let cachedPlacemark = geocodingCache[location] {
                completion(cachedPlacemark)
                return
            }
            
            geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
                if let error = error {
                    print("Geocoding error: \(error)")
                    completion(nil)
                    return
                }
                
                if let placemark = placemarks?.first {
                    self.geocodingCache[location] = placemark
                    completion(placemark)
                } else {
                    completion(nil)
                }
            }
    }
    
    private func showAlbumDetailViewController() {
        let albumDetailViewController = AlbumDetailViewController()
        albumDetailViewController.annotations = existingAnnotations
        navigationController?.pushViewController(albumDetailViewController, animated: true)
    }
    
    @objc private func mapViewTapped(_ gesture: UITapGestureRecognizer) {
        let touchPoint = gesture.location(in: mapView)
        let coordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        currentLocation = CustomLocation(currentLatitude: coordinates.latitude, currentLongitude: coordinates.longitude)
        
        if let currentLocationRecord = currentLocationRecord {
            let touchLocation = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
            let distance = touchLocation.distance(from: currentLocationRecord)
            
            let thresholdDistance: CLLocationDistance = 10.0
            
            if distance <= thresholdDistance {
                let albumDetailViewController = AlbumDetailViewController()
                albumDetailViewController.annotations = annotations.compactMap { $0 as? CustomImageAnnotation }
                navigationController?.pushViewController(albumDetailViewController, animated: true)
                return
            }
        } else {
            let albumDetailViewController = AlbumDetailViewController()
            albumDetailViewController.annotations = annotations.compactMap { $0 as? CustomImageAnnotation }
            navigationController?.pushViewController(albumDetailViewController, animated: true)
            return
        }
        
        if annotationsAlreadyAdded {
            let albumDetailViewController = AlbumDetailViewController()
            albumDetailViewController.annotations = annotations.compactMap { $0 as? CustomImageAnnotation }
            navigationController?.pushViewController(albumDetailViewController, animated: true)
        } else {
            mapView.removeAnnotations(mapView.annotations.filter { $0 is CustomImageAnnotation })
            annotationsAlreadyAdded = true
            addImageAnnotationsAround(centerCoordinate: coordinates)
        }
    }
    
    private func addImageAnnotationsAround(centerCoordinate: CLLocationCoordinate2D) {
        let maxAdditionalAnnotations = 6
        var addedAnnotationsCount = 0
        var index = 0
        
        while addedAnnotationsCount < maxAdditionalAnnotations && index < annotations.count {
            let annotation = annotations[index]
            let coordinate = annotation.coordinate
            let photoUrl = annotation.imageUrl
            let pinCount = annotation.pinCount
            let photoId = annotation.photoId
            let contentId = annotation.contentId
            let date = annotation.date
            
            let angle = Double(addedAnnotationsCount) * (2.0 * Double.pi / Double(maxAdditionalAnnotations))
            let offsetLatitude = centerCoordinate.latitude + 0.0020 * cos(angle)
            let offsetLongitude = centerCoordinate.longitude + 0.0020 * sin(angle)
            
            let newAnnotation = CustomImageAnnotation(
                coordinate: CLLocationCoordinate2D(latitude: offsetLatitude, longitude: offsetLongitude),
                imageUrl: photoUrl,
                pinCount: pinCount,
                photoId: photoId,
                contentId: contentId,
                hidePinCountLabel: false,
                date: date
            )
            newAnnotation.hidePinCountLabel = false
            DispatchQueue.main.async {
                self.mapView.addAnnotation(newAnnotation)
            }
            addedAnnotationsCount += 1
            index += 1
        }
        
        var remainingAnnotations = 0
        let pinCountThreshold = 0
        
        while index < annotations.count {
            let annotationToRemove = annotations[index]
            if remainingAnnotations < 2 && annotationToRemove.pinCount >= pinCountThreshold {
                remainingAnnotations += 1
            } else {
                mapView.removeAnnotation(annotationToRemove)
            }
            index += 1
        }
    }
    
    func setupAnnotation(location: CLLocation, imageUrl: String, pinCount: Int, photoId: Int, contentId: Int, date: String) {
        reverseGeocode(location: location) { placemark in
            guard let placemark = placemark else { return }
            let imageAnnotation = CustomImageAnnotation(
                coordinate: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude),
                imageUrl: imageUrl,
                pinCount: pinCount,
                photoId: photoId,
                contentId: contentId,
                hidePinCountLabel: false,
                date: date
            )
            DispatchQueue.main.async {
                self.mapView.addAnnotation(imageAnnotation)
            }
        }
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
            DispatchQueue.main.async {
                self.mapView.centerToLocation(location)
            }
            currentLocationRecord = location
            setupAnnotation(location: location, imageUrl: annotation.imageUrl, pinCount: annotations.count, photoId: annotation.photoId, contentId: annotation.contentId, date: annotation.date)
        }
        
        guard let location = locations.first else { return }
        
        if !isMapCentered {
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: center, span: span)
            mapView.setRegion(region, animated: true)
            isMapCentered = true
        }
        
        if locations.isEmpty {
            locationManager.stopUpdatingLocation()
        } else {
            //            print(locations, "locations")
        }
    }
    
    func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
}
