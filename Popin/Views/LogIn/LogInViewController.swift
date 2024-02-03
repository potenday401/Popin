//
//  LogInViewController.swift
//  Popin
//
//  Created by 나리강 on 2/4/24.
//

import Foundation

 final class LogInViewController: BaseViewController {

     let mainView = LogInView()
     override func loadView() {
         self.view = mainView
     }

     var viewModel: LogInViewModel?

     override func configure() {
         mainView.loginButton.addTarget(self, action: #selector(clickedButton) , for: .touchUpInside)
     }

     @objc func clickedButton() {
         self.navigationController?.pushViewController(HomeViewController(), animated: true)
     }

 }
