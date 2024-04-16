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
    private let containerView = UIView()
    private let mapView = MKMapView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        searchCompleter.delegate = self
        setupResultMap()
        navigationItem.hidesBackButton = true
    }
    
    private func setupSearchBar() {
        searchBar.placeholder = "장소 검색 (ex. 강남역)"
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        view.addSubview(searchBar)
        
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.height.equalTo(50)
        }
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
        for result in searchResults {
            let label = UILabel()
            label.text = result.title
            label.textColor = .gray
            label.layer.cornerRadius = 5
            label.clipsToBounds = true
            label.textAlignment = .center
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
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // Handle errors if needed
    }
}
