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

final class CustomImageAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let imageUrl: String
    var pinCount: Int = 0
    var photoId:Int
    var contentId:Int
    
    init(coordinate: CLLocationCoordinate2D, imageUrl: String, pinCount: Int, photoId:Int, contentId:Int) {
        self.coordinate = coordinate
        self.imageUrl = imageUrl
        self.pinCount = pinCount
        self.photoId = photoId
        self.contentId = contentId
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
//        mapView.delegate = self
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
        containerView?.removeFromSuperview()
        let containerView = UIView()
        self.containerView = containerView
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
        
        view.addSubview(selectButton)
        
        selectButton.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.top).offset(25)
            make.trailing.equalTo(view.snp.trailing).offset(-326)
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
        
        view.addSubview(cancelButton)
        cancelButton.isHidden = true
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.top).offset(25)
            make.trailing.equalTo(view.snp.trailing).offset(-326)
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
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        
        scrollView.addSubview(stackView)
        
        let numberOfColumns = annotations.count/2
        let numberOfRows = 2
        
        for _ in 0..<numberOfRows {
            let rowView = UIStackView()
            rowView.axis = .horizontal
            rowView.distribution = .fillEqually
            rowView.spacing = 0
            
            for columnIndex in 0..<numberOfColumns {
                let iconView = UIView()
                var imageUrl: URL?
                var photoId: Int?
                var contentId: Int?
                
                for annotation in annotations {
                    if let url = URL(string: annotation.imageUrl) {
                        imageUrl = url
                        //                        print("image not nil")
                    } else {
                        //                        print("image nil")
                    }
                    
                    photoId = annotation.photoId
                    contentId = annotation.contentId
                    if let photoId = photoId, let contentId = contentId {
                        let combinedTag = (photoId << 16) | contentId
                        iconView.tag = combinedTag
                    }
                }
                
                var imageView: UIImageView = {
                    let imageView = UIImageView()
                    imageView.contentMode = .scaleAspectFit
                    imageView.kf.setImage(with: imageUrl)
                    return imageView
                }()
                
                iconView.addSubview(imageView)
                imageView.snp.makeConstraints { make in
                    make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
                    make.width.equalTo(86)
                    make.height.equalTo(86)
                }
                imageView.layer.cornerRadius = 12
                imageView.layer.masksToBounds = true
                
                let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(iconViewTapped(_:)))
                iconView.addGestureRecognizer(tapGestureRecognizer)
                iconView.isUserInteractionEnabled = true
                
                rowView.addArrangedSubview(iconView)
            }
            stackView.addArrangedSubview(rowView)
        }
        
        containerView.addSubview(selectButton)
        selectButton.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.top).offset(8)
            make.trailing.equalTo(containerView.snp.trailing).offset(-16)
        }
        scrollView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(selectButton.snp.bottom).offset(8)
        }
        stackView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        scrollView.contentSize = CGSize(width: stackView.frame.size.width, height: stackView.frame.size.height)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
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
            guard let tag = iconView.tag as? Int else { continue }
            let photoId = tag >> 16
            let contentId = tag & 0xFFFF
            deleteResource(with: photoId, and: contentId)
        }
        selectedIconViews.removeAll()
        //        isSelectionEnabled = false
        cancelButton.isHidden = true
        deleteButton.isHidden = true
        selectButton.isHidden = false
        
    }
    
    private func deleteResource(with photoId: Int, and contentId: Int) {
        print(photoId, contentId, "check")
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
//                        let removedAnnotation = self.annotations.remove(at: index)
//                        self.mapView.removeAnnotation(removedAnnotation)
//                        self.removeAnnotation(with: photoId)
//                        self.refreshAnnotations()
//                        self.setupCardListView()
                        let removedAnnotation = self.annotations.remove(at: index)
                        self.mapView.removeAnnotation(removedAnnotation)
                        self.setupCardListView()
                    }
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
//                        let removedAnnotation = self.annotations.remove(at: index)
//                        self.mapView.removeAnnotation(removedAnnotation)
//                        self.removeAnnotation(with: contentId)
//                        self.refreshAnnotations()
//                        self.setupCardListView()
                        let removedAnnotation = self.annotations.remove(at: index)
                        print(removedAnnotation, "check removed Annotation")
                        self.mapView.removeAnnotation(removedAnnotation)
                        self.setupCardListView()
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
            setupAnnotation(location: CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude), imageUrl: annotation.imageUrl, pinCount: annotation.pinCount, photoId: annotation.photoId, contentId: annotation.contentId)
        }
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
        selectButton.isHidden = true
        deleteButton.isHidden = false
        cancelButton.isHidden = false
        let checkmarkTag = 100
        
        if selectedIconViews.contains(iconView) {
            selectedIconViews.remove(iconView)
            removeCheckmarkFromView(iconView)
            deleteButton.isHidden = true
            selectButton.isHidden = false
            cancelButton.isHidden = true
            
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
        let touchPoint = gesture.location(in: mapView)
        let coordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        currentLocation = CustomLocation(currentLatitude: coordinates.latitude, currentLongitude: coordinates.longitude)
        
        if let currentLocationRecord = currentLocationRecord {
            let touchLocation = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
            let distance = touchLocation.distance(from: currentLocationRecord)
            
            let thresholdDistance: CLLocationDistance = 100.0
            
            if distance <= thresholdDistance {
                //                delegate?.didSelectLocation(annotations: self.annotations)
                let albumViewController = AlbumViewController(accessToken: accessToken)
                albumViewController.annotations = self.mapView.annotations.compactMap { $0 as? CustomImageAnnotation }
                mapView.removeAnnotations(mapView.annotations.filter { $0 is CustomImageAnnotation })
                return
            }
        }
        
        // Remove existing image annotations
        mapView.removeAnnotations(mapView.annotations.filter { $0 is CustomImageAnnotation })
        
        let maxAdditionalAnnotations = 6
        var addedAnnotationsCount = 0
        var index = 0
        let mapCenter = mapView.centerCoordinate
        
        while addedAnnotationsCount < maxAdditionalAnnotations && index < annotations.count {
            let annotation = annotations[index]
            let coordinate = annotation.coordinate
            let photoUrl = annotation.imageUrl
            let pinCount = annotation.pinCount
            let photoId = annotation.photoId
            let contentId = annotation.contentId
            
            let angle = Double(addedAnnotationsCount) * (2.0 * Double.pi / Double(maxAdditionalAnnotations))
            let offsetLatitude = mapCenter.latitude + 0.0020 * cos(angle)
            let offsetLongitude = mapCenter.longitude + 0.0020 * sin(angle)
            
            let newAnnotation = CustomImageAnnotation(
                coordinate: CLLocationCoordinate2D(latitude: offsetLatitude, longitude: offsetLongitude),
                imageUrl: photoUrl,
                pinCount: pinCount,
                photoId: photoId,
                contentId: contentId
            )
            mapView.addAnnotation(newAnnotation)
            
            addedAnnotationsCount += 1
            index += 1
        }
        
        while index < annotations.count {
            let annotationToRemove = annotations[index]
            mapView.removeAnnotation(annotationToRemove)
            index += 1
        }
    }
    
    private func setupAnnotationWithoutPinCount(location: CLLocation, imageUrl: String, photoId: Int, contentId: Int) {
        let newAnnotation = CustomImageAnnotation(
            coordinate: location.coordinate,
            imageUrl: imageUrl,
            pinCount: 0,
            photoId: photoId,
            contentId: contentId
        )
        mapView.addAnnotation(newAnnotation)
    }
    
    func setupAnnotation(location: CLLocation, imageUrl: String, pinCount: Int, photoId: Int, contentId: Int) {
        let imageAnnotation = CustomImageAnnotation(coordinate: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), imageUrl: imageUrl, pinCount: pinCount, photoId: photoId, contentId: contentId)
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
            setupAnnotation(location: location, imageUrl: annotation.imageUrl, pinCount: annotations.count, photoId: annotation.photoId, contentId: annotation.contentId)
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

