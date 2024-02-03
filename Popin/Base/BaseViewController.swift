//
//  File.swift
//  Popin
//
//  Created by 나리강 on 2/3/24.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
        constraints()
        navDesign()
    }
    
    func configure() { }
    func constraints() { }
    func navDesign() {
        let image = UIImage(named: "Logo")
        navigationItem.titleView = UIImageView(image: image)
    }
}
