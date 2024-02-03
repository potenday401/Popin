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
        
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        imageView.layer.cornerRadius = imageView.frame.size.width / 5
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 1.0
        imageView.layer.borderColor = UIColor.white.cgColor
        self.isUserInteractionEnabled = true
        imageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        imageView.addGestureRecognizer(tap)
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
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        print("dkdkdkdkd")
    }
}

class AlbumHeaderView: UIView {
    var backButton: UIButton!
    var plusButton: UIButton!
    weak var delegate: AlbumHeaderViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    private func setupViews() {
        
        let backButton: UIButton = {
            let button = UIButton()
            button.setTitle("Back", for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = .gray
            button.layer.cornerRadius = 18
            button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            return button
        }()
        
        
        let plusButton: UIButton = {
            let button = UIButton()
            button.setTitle("plus", for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = .gray
            button.layer.cornerRadius = 18
            button.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            return button
        }()
        
        
        addSubview(backButton)
        addSubview(plusButton)
        
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(25)
            make.centerY.equalToSuperview().offset(25)
            make.width.equalTo(50)
            make.height.equalTo(33)
        }
        
        plusButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-25)
            make.centerY.equalToSuperview().offset(25)
            make.width.equalTo(50)
            make.height.equalTo(33)
        }
    }
    
    @objc private func backButtonTapped() {
        print("Back button tapped")
        //navigation back...
    }
    
    @objc private func plusButtonTapped() {
        delegate?.plusButtonTapped()
    }
}

class AlbumInfoView: UIView {
    var dateLabel: UILabel!
    var photoCountLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    private func setupViews() {
        dateLabel = UILabel()
        dateLabel.text = "Date: January 30, 2024"
        dateLabel.textColor = .white
        dateLabel.numberOfLines = 0
        
        photoCountLabel = UILabel()
        photoCountLabel.text = "Photos: 10"
        photoCountLabel.textColor = .white
        photoCountLabel.numberOfLines = 0
        
        addSubview(dateLabel)
        addSubview(photoCountLabel)
        
        dateLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        photoCountLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(dateLabel.snp.bottom).offset(8)
            make.trailing.equalToSuperview().offset(-16)
        }
    }
    func updateDate(_ date: String) {
        dateLabel.text = "Date: " + date
    }
    
    func updatePhotoCount(_ count: Int) {
        photoCountLabel.text = "Photos: \(count)"
    }
}



class AlbumViewController: UIViewController, CLLocationManagerDelegate, AlbumHeaderViewDelegate, MKMapViewDelegate {
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
    
    var locationManager: CLLocationManager!
    private var mapView = MKMapView()
    
    var annotations: [CustomImageAnnotation] = []
    
    
    func plusButtonTapped() {
        let cameraViewController = CameraViewController()
        cameraViewController.initialLocation = initialLocation
        navigationController?.pushViewController(cameraViewController, animated: true)
    }
    func setupStatusBarView() {
        let statusBarView = UIView()
        
        view.addSubview(statusBarView)
        
        let headerView = AlbumHeaderView()
        headerView.delegate = self
        statusBarView.addSubview(headerView)
        
        let infoView = AlbumInfoView()
        statusBarView.addSubview(infoView)
        
        statusBarView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(163)
        }
        
        headerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(0)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(134)
        }
        
        infoView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-38)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(0)
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
    
    //todo: annotation 많을때 navigation 체크
    @objc private func mapViewTapped(_ gesture: UITapGestureRecognizer) {
        let touchPoint = gesture.location(in: mapView)
        let coordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        currentLocation = CustomLocation(currentLatitude: coordinates.latitude, currentLongitude: coordinates.longitude)
        
        if let initialLocation = initialLocation {
            let touchLocation = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
            let distance = touchLocation.distance(from: initialLocation)
            
            let thresholdDistance: CLLocationDistance = 100.0
            
            if distance <= thresholdDistance {
                let albumDetailViewController = AlbumDetailViewController()
                
                // Pass the list of annotations to AlbumDetailViewController
                albumDetailViewController.annotations = mapView.annotations.compactMap { $0 as? CustomImageAnnotation }
                print(mapView.annotations.compactMap { $0 as? CustomImageAnnotation }, "???")
                navigationController?.pushViewController(albumDetailViewController, animated: true)
            }
        }
    }
    
    private func setupAnnotation(location: CLLocation) {
        let imageUrl = "https://placekitten.com/200/300"
        let imageAnnotation = CustomImageAnnotation(coordinate: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), imageUrl: imageUrl)
        mapView.addAnnotation(imageAnnotation)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
        setupMapView()
        setupStatusBarView()
        setupCardListView()
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
    
    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func setupCardListView() {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(540)
            make.width.equalToSuperview().multipliedBy(1.1)
            make.height.equalToSuperview().multipliedBy(0.3)
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
            make.top.equalTo(containerView.snp.top).offset(16)
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
        
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.top).offset(16)
            make.trailing.equalTo(view.snp.trailing).offset(-326)
            make.width.equalTo(50)
            make.height.equalTo(33)
        }
        
        let deleteButton: UIButton = {
            let button = UIButton()
            button.setTitle("Delete", for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = .red
            button.layer.cornerRadius = 18
            button.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            button.isHidden = true
            return button
        }()
        
        containerView.addSubview(deleteButton)
        
        deleteButton.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.top).offset(8)
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
        
        let numberOfColumns = 8
        let numberOfRows = 2
        
        for _ in 0..<numberOfRows {
            let rowView = UIStackView()
            rowView.axis = .horizontal
            rowView.distribution = .fillEqually
            rowView.spacing = 0
            
            for columnIndex in 0..<numberOfColumns {
                let iconView = UIView()
                let imageIndex = columnIndex + 1
                let imageUrl = URL(string: "https://placekitten.com/100/100?image=\(imageIndex)")!
                
                let imageView: UIImageView = {
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
    
    @objc private func selectButtonTapped() {
        isSelectionEnabled.toggle()
        updateButtonAppearance()
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
        updateButtonAppearance()
        
        for iconView in selectedIconViews {
            removeCheckmarkFromView(iconView)
        }
        
        selectedIconViews.removeAll()
        
    }
    
    private func updateButtonAppearance() {
        if isSelectionEnabled {
            selectButton.isHidden = true
            cancelButton.isHidden = false
        } else {
            selectButton.isHidden = false
            cancelButton.isHidden = true
        }
    }
    
    @objc private func deleteButtonTapped() {
        // todo....
        
        selectedIconViews.removeAll()
        isSelectionEnabled = false
        updateButtonAppearance()
    }
    
    
    
    private func removeCheckmarkFromView(_ iconView: UIView) {
        if let checkmarkImageView = iconView.viewWithTag(100) as? UIImageView {
            checkmarkImageView.removeFromSuperview()
        }
    }
    
    @objc private func iconViewTapped(_ gesture: UITapGestureRecognizer) {
        guard isSelectionEnabled,
              let iconView = gesture.view as? UIView else {
            return
        }
        
        let checkmarkTag = 100
        
        if selectedIconViews.contains(iconView) {
            selectedIconViews.remove(iconView)
            removeCheckmarkFromView(iconView)
        } else {
            selectedIconViews.insert(iconView)
            let checkmarkImageView = UIImageView(image: UIImage(systemName: "checkmark"))
            checkmarkImageView.tintColor = .blue
            checkmarkImageView.contentMode = .scaleAspectFit
            checkmarkImageView.tag = checkmarkTag
            
            iconView.addSubview(checkmarkImageView)
            checkmarkImageView.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.height.equalTo(24)
            }
        }
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
}
