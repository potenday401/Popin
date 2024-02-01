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
        imageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        imageView.layer.cornerRadius = imageView.frame.size.width / 5
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 1.0
        imageView.layer.borderColor = UIColor.white.cgColor
        
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

class AlbumHeaderView: UIView {
    var backButton: UIButton!
    var plusButton: UIButton!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }

    private func setupViews() {
        backButton = UIButton(type: .system)
        backButton.setTitle("Back", for: .normal)

        plusButton = UIButton(type: .system)
        plusButton.setTitle("Plus", for: .normal)
        plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)

        addSubview(backButton)
        addSubview(plusButton)

        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(25)
            make.centerY.equalToSuperview().offset(25)
        }

        plusButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-25)
            make.centerY.equalToSuperview().offset(25)
        }
    }
    @objc private func plusButtonTapped() {
        print("1")
        let cameraViewController = CameraViewController()
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



class AlbumViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    
    private var cardListView: UITableView!
    private var cardCollectionView: UICollectionView!
    private let cellReuseIdentifier = "CustomCell"
    private let imageUrl = "https://placekitten.com/200/300"
    
    var locationManager: CLLocationManager!
    private var mapView = MKMapView()
    let initialLocation = CLLocation(latitude: 37.517496, longitude: 126.959118)
    
    func setupStatusBarView() {
            let statusBarView = UIView()

            view.addSubview(statusBarView)

            let headerView = AlbumHeaderView()
            statusBarView.addSubview(headerView)

            let infoView = AlbumInfoView()
            statusBarView.addSubview(infoView)

            statusBarView.snp.makeConstraints { make in
                make.top.leading.trailing.equalToSuperview()
                make.height.equalTo(163)
            }

            headerView.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(8)
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(44)
            }

            infoView.snp.makeConstraints { make in
                make.bottom.equalToSuperview().offset(-8)
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(64)
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
        mapView.centerToLocation(initialLocation)
    }

    
    private func setupAnnotation() {
        let imageUrl = "https://placekitten.com/200/300"
        let imageAnnotation = CustomImageAnnotation(coordinate: CLLocationCoordinate2D(latitude: 37.517496, longitude: 126.959118), imageUrl: imageUrl)
        mapView.addAnnotation(imageAnnotation)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupMapView()
        setupStatusBarView()
        setupCardListView()
        setupAnnotation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
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

        let selectButton: UIButton = {
            let button = UIButton()
            button.setTitle("선택", for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = .gray
            button.layer.cornerRadius = 18
            button.addTarget(self, action: #selector(selectButtonTapped), for: .touchUpInside)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            return button
        }()

        view.addSubview(selectButton)

        view.addSubview(selectButton)

        selectButton.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.top).offset(16)
            make.trailing.equalTo(view.snp.trailing).offset(-326)
            make.width.equalTo(50)
            make.height.equalTo(33)
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
        let cameraViewController = CameraViewController()
        navigationController?.pushViewController(cameraViewController, animated: true)
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

