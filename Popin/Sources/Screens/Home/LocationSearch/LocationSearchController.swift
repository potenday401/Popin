//
//  LocationSearchController.swift
//  Popin
//
//  Created by Jihaha kim on 2024/04/15.
//

import UIKit
import MapKit

class LocationSearchController: UIViewController {
    private let searchCompleter = MKLocalSearchCompleter()
    private var searchResults = [MKLocalSearchCompletion]()
    private let searchBar = UISearchBar()
    private let searchBarImage = UIImage()
    private let containerView = UIView()
    private let mapView = MKMapView()
    private let navigationBar: PDSNavigationBar = {
        let navigationBar = PDSNavigationBar()
        navigationBar.title = "장소"
        return navigationBar
    }()
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
            action: #selector(backDidTap)
        )
        navigationBar.rightItem = .init(
            title: "저장",
            target: self,
            action: #selector(sendContents)
        )
        setupSearchBar()
        searchCompleter.delegate = self
        setupResultMap()
        navigationItem.hidesBackButton = true
    }
    
    private func setupSearchBar() {
        searchBar.placeholder = "장소 검색 (ex. 강남역)"
        searchBar.delegate = self
        searchBar.showsCancelButton = false
        searchBar.backgroundColor = .clear
        searchBar.backgroundImage = searchBarImage
        searchBar.searchTextField.textColor = .white
        view.addSubview(searchBar)
        
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.height.equalTo(50)
        }
        searchBar.backgroundColor = .black
    }
    
    private func setupResultMap() {
        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(375)
            make.height.equalTo(50)
        }
        view.addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(375)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    private func geocodeSearchText(_ searchText: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(searchText) { placemarks, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let placemark = placemarks?.first else {
                return
            }
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = placemark.location!.coordinate
            annotation.title = searchText
            self.mapView.addAnnotation(annotation)
            self.mapView.showAnnotations([annotation], animated: true)
        }
    }
    @objc
    private func backDidTap() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    private func sendContents() {
    }
}

extension LocationSearchController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            searchResults.removeAll()
            containerView.subviews.forEach { $0.removeFromSuperview() }
        } else {
            searchCompleter.queryFragment = searchText
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
}

extension LocationSearchController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = Array(completer.results.prefix(3))
        let stackView = UIStackView()
        for (index, result) in searchResults.enumerated() {
            let label = UILabel()
            label.text = result.title
            label.textColor = index == 0 ? .purple100 : .gray
            label.layer.cornerRadius = 5
            label.clipsToBounds = true
            label.textAlignment = .center
            label.isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped(_:)))
            label.addGestureRecognizer(tapGesture)
            stackView.addArrangedSubview(label)
            geocodeSearchText(result.title)
        }
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        
        containerView.subviews.forEach { $0.removeFromSuperview() }
        containerView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.top).offset(10)
            make.leading.equalTo(containerView.snp.leading).offset(10)
            make.trailing.equalTo(containerView.snp.trailing).offset(-10)
            make.bottom.equalTo(containerView.snp.bottom).offset(-10)
            make.height.equalTo(20)
        }
    }
    
    @objc private func labelTapped(_ gesture: UITapGestureRecognizer) {
        guard let tappedLabel = gesture.view as? UILabel else { return }
        let selectedText = tappedLabel.text ?? ""
        handleSelectedText(selectedText)
    }
    
    private func handleSelectedText(_ text: String) {
            print(text, "area check")
    }
}


