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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        searchCompleter.delegate = self
        searchCompleter.filterType = .locationsOnly
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
