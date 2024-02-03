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
        setNavibar()
    }
    
    func configure() { }
    func constraints() { }
    func setNavibar() {
        
        let logoImage = UIImage(named: "Logo")
        self.navigationItem.titleView = UIImageView(image: logoImage)
    }
}
