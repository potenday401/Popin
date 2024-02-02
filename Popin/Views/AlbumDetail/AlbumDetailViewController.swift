//
//  AlbumDetailViewController.swift
//  fourpin
//
//  Created by Jihaha kim on 2024/01/30.
//
import UIKit

class AlbumDetailViewController: UIViewController {
    var annotations: [CustomImageAnnotation] = []
    
    lazy var carousel: Carousel = {
        let urls = annotations.map { URL(string: $0.imageUrl) }.compactMap { $0 }
           return Carousel(frame: .zero, urls: urls)
       }()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            setupHierarchy()
            setupComponents()
            setupConstraints()
        }
        
        override func loadView() {
            let view = UIView()
            view.backgroundColor = .systemBackground
            self.view = view
        }
        
        func setupHierarchy() {
            self.view.addSubview(carousel)
        }
        
        func setupComponents() {
            carousel.translatesAutoresizingMaskIntoConstraints = false
        }
        
        func setupConstraints() {
            NSLayoutConstraint.activate([
                carousel.topAnchor.constraint(equalTo: view.topAnchor),
                carousel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                carousel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                carousel.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        }
}
