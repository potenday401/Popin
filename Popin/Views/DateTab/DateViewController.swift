//
//  DateViewController.swift
//  Popin
//
//  Created by 나리강 on 2/1/24.
//

import UIKit

final class DateViewController: BaseViewController {

    let mainView = DateView()
    override func loadView() {
        self.view = mainView
    }
    

}
